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
+------------+-----------------+------+-----+---------+-------+
| Field      | Type            | Null | Key | Default | Extra |
+------------+-----------------+------+-----+---------+-------+
| LUNno      | int(11)         | NO   | PRI | 0       |       |
| tstamp     | datetime        | NO   | PRI | NULL    |       |
| counter_id | int(11)         | NO   | PRI | 0       |       |
| value      | double unsigned | NO   |     | 0       |       |
+------------+-----------------+------+-----+---------+-------+

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
		
			While (list($sKey, $iVal) = each($aRecord))
			{
				if ($iVal !== '')
				{
					$aIns	= array(
						'LUNno'		=> $iLUN,
						'tstamp'	=> $sDate,
						'counter_id'	=> $this->getCounterId($sKey),
						'value'		=> $iVal);
					$this->oDB->insert('LUN_counters', $aIns);
				}
					
			}
		} else 
		{
			fwrite(STDERR, "Datestamp unrecognised\n");
		}
	}
	
}

?>