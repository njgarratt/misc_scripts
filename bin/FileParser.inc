<?php

/*
	Abstract Class
	Read one line at a time from a passed file descriptor and populate
	a record array ready for insertion into a DB
*/
abstract class Parser implements Iterator 
{

	public  $rFD;
	protected  $aHeader 	= array();
	protected  $aRecord	= array();
	protected  $iLinNo		= 0; // how many lines have we read?
	protected $bValid		= FALSE; // was the last input valid?

	public function __construct(&$rFD, $aOpts)
	{
		$this->rFD	= &$rFD;
		$this->setOpts($aOpts);
	}
	
	/* set parser options. called by constructor */
	abstract public function setOpts($aOpts);
	
	
	abstract public function readLine();
	
	
	protected  function populateHeader(&$aTmp)
	{
	}

	protected  function populateRecord()
	{

	}
	
	/*
	 * generate a hash value for this file
	 */
	public function genHash($sFile)
	{
	
	}
	
	public function key()
	{
		//fwrite(STDOUT,"key\n");	
		return $this->iLineNo;
	}
	
	/* return the poplulated record */
	public function current()
	{
		//fwrite(STDOUT,"current\n");
		return $this->aRecord;
	}

}

/*
	Extension of the Parser abstract class to handle CSV input
	First line of input is assumed to be header data
*/

class ParseCSV extends Parser
{
	protected  $aOpts	= array();
	protected  $aLine	= array();
	
	
	public function setOpts($aOpts)
	{
		if (isset($aOpts['delimiter']))
		{
			$this->aOpts['delimiter']	= $aOpts['delimiter'];
		} else 
		{
			$this->aOpts['delimiter']	= ',';
		}
			if (isset($aOpts['enclosure']))
		{
			$this->aOpts['enclosure']	= $aOpts['enclosure'];
		} else 
		{
			$this->aOpts['enclosure']	= '"';
		}
	}
	
	public function readLine()
	{
		if ($this->aLine = fgetcsv($this->rFD, 8192, $this->aOpts['delimiter'], $this->aOpts['enclosure']))
		{
			++$this->iLineNo;
			return TRUE;
		} else
		{
			fwrite(STDERR, "No more data to read on ". $this->rFD);
			return FALSE;
		}
	}
	
	public function rewind()
	{
			//fwrite(STDOUT,"rewind\n");
			rewind($this->rFD);
			$this->iLineNo	= 0;
			if ($this->readLine())
			{
				$this->populateHeader();
				if ($this->readLine())
				{
					$this->populateRecord();
					$this->bValid	= TRUE;
					return TRUE;
				}
			}
			$this->vValid	= FALSE;
			return FALSE;
	}
	
	public function next()
	{
		//fwrite(STDOUT,"Next\n");
		// clear the previous record
		$this->aRecord	= array();
		if ($this->readLine())
		{
			$this->populateRecord();
			$this->bValid	= TRUE;
		} else
		{
			fwrite(STDERR, "No more data to read on ". $this->rFD);
			$this->bValid	= FALSE;
		}
	}
	
	public function valid()
	{
		//fwrite(STDOUT,"valid\n");
		return $this->bValid;
	}
	
	public function first()
	{
		$this->populateHeader();
	}
	
	protected  function populateHeader()
	{
		// we should step through and santise first
		$this->aHeader	= $this->aLine;
	}

	/* populate an associative array of field_name => value */
	protected  function populateRecord()
	{
		while (list($iKey,$sVal) = each($this->aLine))
		{
			// some sanitisation is required
			$this->aRecord[$this->aHeader[$iKey]]	= $sVal;
		}
	}
}

/*
 * File Parser Factory
 */
class FileParser
{
	var $oParser;

	public static function factory($sFile, $sType, $aOpts)
	{
		$rFd	= fopen($sFile, 'r');
		if ($rFd == FALSE)
		{
			throw new Exception('Unable to open '. $sFile .' for reading!');
		}
		switch ($sType)
		{
			case 'csv': $oParser	= new ParseCSV($rFd, $aOpts);
				break;
			default: throw new Exception('No suitable parser found for type '. $sType);
				break;
		}
		return $oParser;
	}
}

?>
