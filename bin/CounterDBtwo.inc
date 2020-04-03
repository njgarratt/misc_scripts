<?php 
/*
 * Class for handling all database related activities for the storage and retrieval
 * performance counters
 * 
mysql> describe LUNs;
+------------+------------+------+-----+---------+----------------+
| Field      | Type       | Null | Key | Default | Extra          |
+------------+------------+------+-----+---------+----------------+
| LUNno      | int(11)    | NO   | PRI | NULL    | auto_increment |
| devno      | int(11)    | NO   |     | 0       |                |
| acc_no     | int(11)    | NO   |     | 0       |                |
| LUN_name   | char(255)  | NO   |     |         |                |
| array_name | char(255)  | NO   |     |         |                |
| status     | tinyint(3) | NO   |     | 0       |                |
+------------+------------+------+-----+---------+----------------+

mysql> describe LUN_counters;
+--------+-----------------+------+-----+---------+-------+
| Field  | Type            | Null | Key | Default | Extra |
+--------+-----------------+------+-----+---------+-------+
| LUNno  | int(11)         | NO   | PRI | 0       |       |
| tstamp | datetime        | NO   | PRI | NULL    |       |
| value1 | double unsigned | NO   |     | 0       |       |
| value2 | double unsigned | NO   |     | 0       |       |
| value3 | double unsigned | NO   |     | 0       |       |
+--------+-----------------+------+-----+---------+-------+

mysql> describe counters;
+---------------+-----------+------+-----+---------+----------------+
| Field         | Type      | Null | Key | Default | Extra          |
+---------------+-----------+------+-----+---------+----------------+
| counter_id    | int(11)   | NO   | PRI | NULL    | auto_increment |
| counter_label | char(255) | NO   | MUL |         |                |
+---------------+-----------+------+-----+---------+----------------+

 * requires Zend lib Adapator
 */
require_once 'Zend/Loader/Autoloader.php';
Zend_Loader_Autoloader::getInstance();
date_default_timezone_set('Europe/London');

class CounterDB
{
	
	private $aCounters	= array();
	private $aObjects	= array();
	private $aTStruct	= array();
	private $oDB;
	
	public function __construct()
	{
		$oConfig	= new Zend_Config_Ini('./config.ini', 'test');
		$this->oDB = Zend_Db::factory($oConfig->database);
		$this->oDB->setFetchMode(Zend_Db::FETCH_ASSOC);
		$this->init();
		
	}
	
	private function init()
	{
		$this->aCounters	= array();
		$this->aObjects		= array();
		$this->aTStruct		= array();
	}
	
	/*
	 * shorten a long string in a unique way
	 * 
	 */
	public function shorten255($sName)
	{
		if (strlen($sName) <= 255)
		{
			return $sName;
		} else 
		{
			$sMD5	= md5(substr($sName,223));
			return	substr($sName,0,222) . $sMD5;
		}
	}
	
	
	/*
	 * retrieve the names of the currently defined value columns indexed on counter_id
	 */
	private function getTStruct()
	{
		$this->TStruct	= array();
		// we should use a more portable method than describe
		$sSQL		= 'DESCRIBE LUN_counters2';
		$aResult	= $this->oDB->fetchAll($sSQL);
		
		if ($aResult)
		{
			while (list(,$aTmp) = each($aResult))
			{
				// can we assume these will be in the defined order?
				if (is_numeric($i = substr($aTmp['Field'], 5)))
				{
					$this->aTStruct[$i]		= $aTmp['Field'];
				}
			}
		}
		print_r($this->TStruct);
	}
	
	/*
	 * create a new counter coulumn
	 */
	private function createCounterCol($iCounterId)
	{
		$sCol	= 'value'. (int)$iCounterId;
		$sSQL	= 'ALTER TABLE LUN_counters2 ADD `'. $sCol .'` double unsigned NOT NULL DEFAULT 0';
		try 
		{
			$this->oDB->query($sSQL);
			return $sCol;	
		} catch (Zend_Db_Adapter_Exception $eException)
		{
			fwrite(STDERR, 'Unable to alter table:'. $eException->getMessage());
			return FALSE;
		}
	}
	
	private function getCol($iCounterId)
	{
		if (isset($this->aTStruct[$iCounterId]))
		{
			return $this->aTStruct[$iCounterId];
		} else if (count($this->aTStruct))
		{
			// we have an array of colums but ours isn't there - we need to create it
			if ($sCol = $this->createCounterCol($iCounterId))
			{
				// refresh our columns array
				$this->getTStruct();
				return $sCol;
			} else 
			{
				return FALSE;
			}
		} else 
		{
			// maybe this is the first time we have been called. populate colums array
			$this->getTStruct();
			// this time should work
			return $this->getCol($iCounterId);		
		}
	}
	

	/* 
	 * retrieve a counter_id if one exists ($his->aCounters, the DB) or insert and retrieve one
	 * and populate $this->aCounters for future reference
	 */
	public function getCounterId($sCounter)
	{

			//var_dump($this->aObjects);
			$sCounter		= trim($sCounter);
	
		if ($iCounterId = array_search($sCounter, $this->aCounters))
		{
			return $iCounterId;		
		} else 
		{
			$sSQL	= "SELECT counter_id 
			FROM  counters
			WHERE 
			counter_label = ". $this->oDB->quote($sCounter);
			echo $sSQL;
						
			$aResult = $this->oDB->fetchRow($sSQL);
						
			if ($aResult)
			{
				//echo "result:" . count($aResult);
				// we have a result
				$iCounterId				= $aResult['counter_id'];
				$this->aCounters[$iCounterId]	= $sCounter;
				return $iCounterId;
			} else
			{
								// this is the first time we have encountered this one
				$this->oDB->insert('counters', array('counter_label' => $sCounter));
				$iCounterId	= $this->oDB->lastInsertId();
				$this->aCounters[$iCounterId]	= $sCounter;
				return $iCounterId;
			}
		}
	}
	
	/*
	 * retrieve all available counters suitable for a dropdown or multi-select
	 * an populate into $this->aCounters
	 */
	public function getCounters()
	{
		$sSQL		= 'SELECT counter_id, counter_lable FROM counters where 1';
		$aResult	= $this->oDB->fetchAll();
		
		if ($aResult)
		{
			$iCnt	= count($aResult);
			for ($i = 0; $i < $iCnt; $i++)
			{
				$this->aCounters[$aResult[$i]['counter_id']]	= $this->aCounters[$aResult[$i]['counter_label']];	
			}
			return $this->aCounters;
		} else
		{
			return FALSE;
		}
	}
	
	/* NOTE: LUN here can be any storage object (LUN, SP)
	 * retrieve a LUNno if one exists ($his->aObjects, the DB) or insert and retrieve one
	 * and populate $this->aObjects for future reference
	 */
	public function getLUNId($sLUN_name, $sArray_name)
	{

			//var_dump($this->aObjects);
			$sLUN_name		= $this->shorten255(trim($sLUN_name));
			$sArray_name	= trim($sArray_name);
			$sVal	=	$sLUN_name .':'. $sArray_name;
	
		if ($iLUN = array_search($sVal, $this->aObjects))
		{
			return $iLUN;		
		} else 
		{
			$sSQL	= "SELECT LUNno, LUN_name, array_name 
			FROM LUNs 
			WHERE 
			LUN_name = ". $this->oDB->quote($sLUN_name) ." AND 
			array_name = ". $this->oDB->quote($sArray_name);
			echo $sSQL;
						
			$aResult = $this->oDB->fetchRow($sSQL);
						
			if ($aResult)
			{
				//echo "result:" . count($aResult);
				// we have a result
				$iLUN					= $aResult['LUNno'];
				$sLUN_name				= $aResult['LUN_name'];
				$this->aObjects[$iLUN]	= $sVal;
				return $iLUN;
			} else
			{
								// this is the first time we have encountered this one
				$aLUN					= $this->tokeniseLUNName($sLUN_name, $sArray_name);
				var_dump($aLUN);
				$this->oDB->insert('LUNs', $aLUN);
				$iLUN	= $this->oDB->lastInsertId();
				$this->aObjects[$iLUN]	= $sVal;
				return $iLUN;
			}
		}
	}
	
	/*
	 * Since array#/device#/customer# must be inferred from name
	 * try and identify these components here
	 * we need a flag and/or a placeholder for later 
	 * manual mappping when we fail
	 */
	public function tokeniseLUNName($sLUN_name, $sArray_name)
	{
		$aLUN	= array(
			'devno'			=> 0,
			'acc_no'		=> 0,
			'LUN_name'		=> $sLUN_name,
			'array_name'	=> $sArray_name,
			'status'		=> 1);
		$aTmp	= split('-', $sLUN_name);
		foreach ($aTmp as $sTok)
		{
			if (is_numeric($sTok))
			{
				if ($aLUN['acc_no'] == 0)
				{
					$aLUN['acc_no']	= $sTok;
				} else 
				{
					$aLUN['devno']	= $sTok;
				}
			}
		}
		return $aLUN;
	}
	
	/*
	 * @returns boolean
	 * Have we previously processed this file?
	 */
	public function processFile($sFile, $sHash)
	{

	}
	
	public function insertCounterRec($aRecord)
	{
		// first get a LUN ID
		$iLUN	= $this->getLUNId($aRecord['Object Name'], $aRecord['Owner Array Name']);
		if ($oDT = DateTime::createFromFormat('m/d/Y H:i:s', $aRecord['Poll Time']))
		{
			$sDate	= $oDT->format('Y-m-d H:i:s');
			unset($aRecord['Object Name']);
			unset($aRecord['Owner Array Name']);
			unset($aRecord['Poll Time']);
		
			$aIns	= array(
						'LUNno'		=> $iLUN,
						'tstamp'	=> $sDate);
			
			while (list($sKey, $iVal) = each($aRecord))
			{
				if ($iVal !== '')
				{
					
					if ($iCounterId	= $this->getCounterId($sKey) and $sCol = $this->getCol($iCounterId))
					{
						$aIns[$sCol]	= $iVal;
					}
				}
			}

			try 
			{
				$this->oDB->insert('LUN_counters2', $aIns);
			} catch (Zend_Db_Adapter_Exception $eException)
			{
				fwrite(STDERR, 'INSERT error:'. $eException->getMessage());
			} catch (Zend_Exception $eException)
			{
				fwrite(STDERR, 'INSERT error:'. $eException->getMessage());
			} 
		} else 
		{
			fwrite(STDERR, "Datestamp unrecognised\n");
		}
	}
	
}

?>
