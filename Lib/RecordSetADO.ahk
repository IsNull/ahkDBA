;namespace DBA

/*
	Represents a result set of ADO
	http://www.w3schools.com/ado/ado_ref_recordset.asp
*/
class RecordSetADO extends DBA.RecordSet
{
	_adoRS := 0 ; ado recordset

	__New(sql, adoConnection, editable = false){
		this._adoRS := ComObjCreate("ADODB.Recordset")
		if(editable)
			this._adoRS.Open(sql, adoConnection, ADO.CursorType.adOpenKeyset, ADO.LockType.adLockOptimistic, ADO.CommandType.adCmdTable)
		else
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
	
	AddNew(){
		if(this.IsValid())
		{
			this._adoRS.AddNew()
		}	
	}
	
	MoveNext() {
		if(this.IsValid())
		{
			this._adoRS.MoveNext()
		}
	}
	
	Delete(){
		if(this.IsValid() && !this.getEOF())
		{
			this._adoRS.Delete(ADO.AffectEnum.adAffectCurrent)
		}
	}
	
	Update(){
		if(this.IsValid() && !this.getEOF())
		{
			this._adoRS.Update()
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

