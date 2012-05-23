#NoEnv
#Warn, LocalSameAsGlobal, Off
SetWorkingDir %A_ScriptDir% 
#Include <DBA>


global initialSQL := "SELECT * FROM Test"
global databaseType := ""
currentDB := 0 ; current db connection

Gui, +LastFound +OwnDialogs
Gui, Margin, 10, 10


Gui, Add, Text, x10 w100 h20 0x200 , DB Connection, 
Gui, Add, ComboBox, x+0 ym w400 vddDatabaseConnection, %A_ScriptDir%\TEST.DB||Server=localhost;Port=3306;Database=test;Uid=root;Pwd=toor;|Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\Users\IsNull\Downloads\babbel\pas.mdb
Gui, Add, DropDownList, yp xp+420 w100 vddDatabaseType, % ArrayToGuiString(DBA.DataBaseFactory.AvaiableTypes, true)
Gui, Add, Button, gReConnect yp xp+140 w80, .connect

Gui, Add, Text, x10 yp+35  w100 h20 0x200 vTX, SQL statement:
Gui, Add, ComboBox, x+0  w520 vSQL Sort, %initialSQL%||
Gui, Add, Button, yp xp+560 w80 hp vRun gRunSQL Default, .run



Gui, Add, Text, xm h20 w100 0x200, Table name:
Gui, Add, GroupBox, xm w780 h330 , Results
Gui, Add, ListView, xp+10 yp+18 w760 h300 vResultsLV,
Gui, Add, Button, gTestRecordSetClick, [Test RecordSet]
Gui, Add, StatusBar,
Gui, Show, , sqlite test oop

return


ReConnect:
	Gui, submit, NoHide
	
	databaseType := ddDatabaseType
	connectionString := ddDatabaseConnection

	currentDB := DBA.DataBaseFactory.OpenDataBase(databaseType, connectionString)

	if(IsObject(currentDB))
	{
		if(databaseType = "SQLite"){
			CreateTestDataSQLite(currentDB)
		}else if(databaseType = "mySQL"){
			CreateTestDataMySQL(currentDB)
		}

		TestInsert(currentDB)

		gosub, RunSQL
	}else{
		MsgBox Failed to create connection. Check your Connection string and DB Settings!
	}
return


TestRecordSetClick:
	Gui, submit, NoHide
	TestRecordSet(currentDB, SQL)
return

GuiClose:
	if(IsObject(currentDB))
		currentDB.Close()
Exitapp

;=======================================================================================================================
; Execute SQL-Statement
;=======================================================================================================================
RunSQL:
	GuiControlGet, SQL
	

	
	if(IsObject(currentDB))
	{
		state := ""
		if(Trim(SQL) == "")
		{
		   SB_SetText("No SQL entered")
		   Return
		}
		res := currentDB.Query(SQL)
		
		if(is(res, DBA.Table)){
			SB_SetText("The Selection yielded " res.Count() " results.")
			ShowTable("ResultsLV", res)
		} else {
			state := "Non selection Query executed! Ret: " res
		}
		
		if(!IsObject(res) && !res){
				state := "!# " currentDB.GetLastErrorMsg() " " res
		}
		if(state != "")
			SB_SetText(state)
	}else {
		MsgBox No Connection avaiable. Please connect to a db first!
	}
return




TestInsert(mydb){
	
	
	records := new Collection()
	
	;Table Layout: Name, Fname, Phone, Room
	
	record := {}
	record.Name := "Hans"
	record.Fname := "Meier"
	record.Phone := "93737337"
	record.Room := "wtf is room!? :D"
		
	record2 := {}
	record2.Name := "Marta"
	record2.Fname := "Heilia"
	record2.Phone := "1234111"
	record2.Room := "Don't be that strange!"	
	
	records.Add(record)
	records.Add(record2)	
				
	mydb.InsertMany(records, "Test")
}


TestRecordSet(db, sQry){
	rs := db.OpenRecordSet(sQry)
	while(!rs.EOF){	
		name := rs["Name"] 
		phone := rs["Phone"]

		MsgBox %name% %phone%
		rs.Update()
		rs.MoveNext()
	}
	rs.Close()
	MsgBox done :)
}

ShowTable(listView, table){
	
	GuiControl, -ReDraw, %listView%
	Gui, ListView, %listView%
	if(!is(table, DBA.Table))
		throw Exception("Table Object expected!",-1)
	
	LV_Delete()
	Loop, % LV_GetCount("Column")
	   LV_DeleteCol(1)
   
	for each, colName in table.Columns 
		LV_InsertCol(A_Index,"", colName)
	
	columnCount := table.Columns.Count()
	
	for each, row in table.Rows
	{
		rowNum := LV_Add("", "")
		Loop, % columnCount
			LV_Modify(rowNum, "Col" . A_index, row[A_index])
	}
	LV_ModifyCol()
	GuiControl, +ReDraw, %listView%
}

CreateTestDataSQLite(db){
	
	try
	{
		SB_SetText("Create Test Data")
		
		db.Query("CREATE TABLE Test (Name, Fname, Phone, Room, PRIMARY KEY(Name ASC, FName ASC));")
		
		db.BeginTransaction()
		{
			_SQL := "INSERT INTO Test VALUES('Name#', 'Fname#', 'Phone#', 'Room#');"
			sQry := ""
			i := 501
			Loop, 1000 {
			   StringReplace, cSQL, _SQL, #, %i%, All
				sQry .= cSQL
			   i++
			}
			if (!db.Query(sQry)) {
				  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError()
				  MsgBox, 0, ERROR from EXEC, %Msg%
			}
		}db.EndTransaction()
	}catch{
		;// ignore
	}
}

CreateTestDataMySQL(db){
	
	try
	{
		SB_SetText("Create Test Data")

		createTableSQL =
		(Ltrim
				CREATE TABLE IF NOT EXISTS Test (
				  Name VARCHAR(250),
				  Fname VARCHAR(250),
				  Phone VARCHAR(250),
				  Room VARCHAR(250),
				  PRIMARY KEY (Name, Fname)
				`)
		)		
		db.Query(createTableSQL)


		db.BeginTransaction()
		{
			_SQL := "('Name#', 'Fname#', 'Phone#', 'Room#')"
			sQry := "INSERT INTO Test (Name, Fname, Phone, Room)`nVALUES`n"
			i := 1
			
			Loop, 500 {
			   StringReplace, cSQL, _SQL, #, %i%, All
				sQry .= cSQL ",`n"
			   i++
			}
			
			sQry := substr(sQry,1,StrLen(sQry)-2) ";"
			
			
			if (!db.Query(sQry)) {
				  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError()
				  MsgBox, 0, ERROR from EXEC, %Msg%
			}

			
		}db.EndTransaction()
	}catch{
		;// ignore
	}
}


ArrayToGuiString(items , bSelectFirst){
	str := ""
	for each, item in items
		str .= item "|" ((bSelectFirst && A_Index == 1) ? "|" : "")
	return str
}
