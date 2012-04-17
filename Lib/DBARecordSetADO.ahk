#NoEnv
#Include <DBADataBaseAbstract>


/*
	Represents a result set of ADO
	http://www.w3schools.com/ado/ado_ref_recordset.asp
*/
class DBARecordSetADO extends DBARecordSet
{
	_adoRS := 0 ; ado recordset

	__New(sql, adoConnection){
		this._adoRS := ComObjCreate("ADODB.Recordset")
		this._adoRS.Open(sql, adoConnection)
	}

	/*
		Is this RecordSet valid?
	*/
	IsValid(){
		return (IsObject(this._adoRS))
	}
	
	/*
		Returns an Array with all Column Names
	*/
	getColumnNames(){	
		
		colNames := new Collection()
		
		for adoField in this._adoRS.Fields
			colNames.add(adoField.Name)
		
		return colNames
	}
		
	getEOF(){
		return this._adoRS.EOF
	}
	
	
	MoveNext() {
		if(this.IsValid())
		{
			this._adoRS.MoveNext()
		}
	}
	
	

	Reset() {
		if(this.IsValid()){
			this._adoRS.MoveFirst()	
		}
	}
	
	Count(){
		cnt := 0
		if(this.IsValid())
			cnt := this._adoRS.RecordCount	
		return cnt
	}

	
	Close() {
		if(this.IsValid())
			this._adoRS.Close()
	}
	
	
	__Get(param){
		
		if(IsObject(param)){
			throw Exception("Expected Index or Column Name!",-1)
		}
		
		if(param = "EOF")
			return this.getEOF()

		if(!IsObjectMember(this, param) && param != "_currentRow"){
			if(this.IsValid())
			{	
				df := this._adoRS.Fields[param]
				return df.Value
			}
		}
	}
}

