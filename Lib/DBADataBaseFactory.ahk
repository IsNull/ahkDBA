#Include <Base>
#Include <DBADataBase>
#Include <DBADataBaseSQLLite>
#Include <DBADataBaseMySQL>
#Include <DBADataBaseADO>

class DBADataBaseFactory
{
	static AvaiableTypes := ["SQLite", "MySQL", "ADO"]
	
	/*
		This static Method returns an Instance of an DataBase derived Object
	*/
	OpenDataBase(dbType, connectionString){
		if(dbType = "SQLite")
		{
			OutputDebug, Open Database of known type [%dbType%]
			SQLite_Startup()
			;//parse connection string. for now assume its a path to the requested DB
			handle := SQLite_OpenDB(connectionString)
			return new DBADataBaseSQLLite(handle)
			
		} if(dbType = "MySQL") {
			OutputDebug, Open Database of known type [%dbType%]
			MySQL_StartUp()
			conData := MySQL_CreateConnectionData(connectionString)
			return new DBADataBaseMySQL(conData)
		} if(dbType = "ADO") {
			OutputDebug, Open Database of known type [%dbType%]
			return new DBADataBaseADO(connectionString)
		} else {
			throw Exception("The given Database Type is unknown! [" . dbType "]",-1)
		}
	}
	
	__New(){
		throw Exception("This is a static class, dont instante it!",-1)
	}
}