<?php

/*
	Step through all arguments presented in argv and return 
	those that are readable files 
*/
class FileArgs implements Iterator
{
	var $DEBUG;
	var $aFiles	= array();
	var $aDirs	= array();
	var $aDirStack	= array();
	var $sFile;
	var $sFilter	= '';
	var $iFilter	= 0;


	public function __construct(&$aFiles, &$aDirs, $sFilter = '')
	{
		global $DEBUG;
		if ($DEBUG)
		{
			$this->DEBUG	= TRUE;
		}
		if (count($aFiles))
		{	
			if ($this->DEBUG)
			{
				fwrite(STDOUT, "Files supplied\n");
			}
			$this->aFiles	= $aFiles;
		}
		if (count($aDirs))
		{
			if ($this->DEBUG)
			{
				fwrite(STDOUT, "Directories supplied\n");
			}	
			$this->aDirs	= $aDirs;
		}

		if ($this->iFilter = strlen($sFilter))
		{
			$this->sFilter	= $sFilter;
		}
	}

	private function DirStack()
	{
		$this->aDirStack	= array(); 

		while (list(,$sDir) = each($this->aDirs))
		{
			if ($this->DEBUG)
			{
				fwrite(STDOUT, "Pushing directory $sDir\n");
			}
			$oIt	= new  DirectoryIterator($sDir);
			if (is_object($oIt))
			{
				array_push($this->aDirStack, $oIt);
			} else 
			{
				fwrite(STDERR, "Cannot instantiate DirectoryIterator\n");
			}
			//print_r($this->aDirStack);
		}
	}

	private function Filter($sName)
	{
		if ($this->iFilter == strlen(stristr($sName, $this->sFilter)))
		{
			return TRUE;
		} else
		{
			if ($this->DEBUG)
			{
				fwrite(STDERR, "File $sName failed filter\n");
			}
			return FALSE;
		}
	}


	public function rewind()
	{
		reset($this->aFiles);
		reset($this->aDirs);
		$this->DirStack();
		$this->next();
	}

	/* process files first */	
	public function next()
	{
		if ($this->DEBUG)
		{
			fwrite(STDOUT, "next\n");
			print_r($this->aFiles);
		}
		if (!count($this->aFiles))
		{
		// we have finished processing all files at this level
			$this->sFile	= '';
			if ($oDir =& array_pop($this->aDirStack))
			{
				//var_dump($oDir);
				while ($oDir->valid())
				{
					$oRet	= $oDir->current();
					$sName	= $oRet->getPathName();
					//var_dump($oRet);
					if ($this->DEBUG)
					{
						fwrite(STDOUT, "DI next ". $sName . "\n");
					}
					if ($oRet->isFile() && $this->Filter($sName))
					{
						fwrite(STDOUT, "Pushing file ". $sName ."\n");	
						array_push($this->aFiles, $sName);
					} else if ($oRet->isDir() && !$oRet->isDot())
					{
						if ($this->DEBUG)
						{
							fwrite(STDOUT, "Pushing $sName\n");
						}
						$oIt	= new  DirectoryIterator($sName);
						array_push($this->aDirStack, $oIt);
					} else 
					{
						if ($this->DEBUG)
						{
							fwrite(STDOUT, "Ignoring object ". $sName ."\n");
						}
					}
					$oDir->next();
				}
				fwrite(STDOUT, "recurse\n");
				$this->next();
			}
		} else
		{
			$this->sFile = array_pop($this->aFiles);
			if ($this->DEBUG)
			{
				fwrite(STDOUT, "current file is ". $this->sFile ."\n");
			}
			return TRUE;
		}
		return FALSE;
	}

	public function current()
	{
		return $this->sFile;
	}

	public function key()
	{
		return key($this->aFiles);
	}

	public function valid()
	{
		if (is_file($this->sFile) && is_readable($this->sFile))
		{
			return TRUE;
		} else
		{
			if ($this->DEBUG)
			{
				fwrite(STDERR, 'File '. $this->sFile .' must exist and be readable' . "\n");
			}
			return FALSE;
		}
	}
}
?>
