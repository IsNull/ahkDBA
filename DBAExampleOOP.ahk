#NoEnv
#Warn, LocalSameAsGlobal, Off
SetWorkingDir %A_ScriptDir% 
#Include <DBA>




global initialSQL := "SELECT * FROM Test"
global databaseType := ""
currentDB := 0 ; current db connection

connectionStrings := A_ScriptDir "\Test\TestDB.sqlite||Server=localhost;Port=3306;Database=test;Uid=root;Pwd=toor;|Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" A_ScriptDir "\Test\TestDB.mdb"

Gui, +LastFound +OwnDialogs
Gui, Margin, 10, 10


Gui, Add, Text, x10 w100 h20 0x200 , DB Connection, 
Gui, Add, ComboBox, x+0 ym w400 vddDatabaseConnection, % connectionStrings
Gui, Add, DropDownList, yp xp+420 w100 vddDatabaseType, % ArrayToGuiString(DBA.DataBaseFactory.AvaiableTypes, true)
Gui, Add, Button, gReConnect yp xp+140 w80, .connect

Gui, Add, Text, x10 yp+35  w100 h20 0x200 vTX, SQL statement:
Gui, Add, ComboBox, x+0  w520 vSQL Sort, %initialSQL%||
Gui, Add, Button, yp xp+560 w80 hp vRun gRunSQL Default, .run



Gui, Add, Text, xm h20 w100 0x200, Table name:
Gui, Add, GroupBox, xm w780 h330 , Results
Gui, Add, ListView, xp+10 yp+18 w760 h300 vResultsLV,
Gui, Add, Button, gTestRecordSetClick, [Test RecordSet]
Gui, Add, Button, gTestBinaryBlobClick, [Test Binary Blob]
Gui, Add, StatusBar,
Gui, Show, , sqlite test oop

return



ReConnect:
	Gui, submit, NoHide
	DoTestInserts := false
	
	databaseType := ddDatabaseType
	connectionString := ddDatabaseConnection

	try {
		
		currentDB := DBA.DataBaseFactory.OpenDataBase(databaseType, connectionString)
		
		if(DoTestInserts)
		{
			try {
				if(databaseType = "SQLite"){
					CreateTestDataSQLite(currentDB)
				}else if(databaseType = "mySQL"){
					CreateTestDataMySQL(currentDB)
				}
			}catch e
				MsgBox,16, Error, % "Failed to create Test Data.`n`nException Detail:`n" e.What "`n"  e.Message
			
			try {
				TestInsert(currentDB)
			}catch e
				MsgBox,16, Error, % "Test of Recordset Insert failed!`n`nException Detail:`n" e.What "`n"  e.Message
		}
		

		GoSub, RunSQL
	}
	catch e
		MsgBox,16, Error, % "Failed to create connection. Check your Connection string and DB Settings!`n`nException Detail:`n" e.What "`n"  e.Message


return


TestRecordSetClick:
	Gui, submit, NoHide
	TestRecordSet(currentDB, SQL)
return

TestBinaryBlobClick:
	Gui, submit, NoHide
	TestBinaryBLob(currentDB)
	
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
		
		try {
		
			res := currentDB.Query(SQL)
		
			if(is(res, DBA.Table)){
				SB_SetText("The Selection yielded " res.Count() " results.")
				ShowTable("ResultsLV", res)
			} else {
				state := "Non selection Query executed! Ret: " res
			}
			
		} catch e
			state := "!# " e.What " " e.Message


		if(state != "")
			SB_SetText(state)
	}else {
		MsgBox,16, Error, No Connection avaiable. Please connect to a db first!
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

TestBinaryBLob(db){
	static imagePath := A_scriptdir "\Test\boom.png"

	if(!IsObject(db))
		throw Exception("ArgumentExcpetion: db must be a DBA DataBase Object")
	
	imgBuffer := new MemoryBuffer()
	imgBuffer.CreateFormFile(imagePath)
	
	;MsgBox % imgBuffer.ToString()
	;imgBuffer.WriteToFile(A_ScriptDir "\hui.jpg")
	
	record := {}
	record.Name  := "Test Image"
	;record.Image := imgBuffer
		
	db.Insert(record, "ImageTest") ; Insert this record into Table 'ImageTest'
	
	imgBuffer.Free()
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
		
		db.Query("CREATE TABLE TestImage (Name, Image BLOB, PRIMARY KEY(Name ASC));")
		
		InsertTestData(db)
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

		InsertTestData(db)
		
	}catch{
		;// ignore
	}
}

InsertTestData(db)
{
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
			  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
			  FileAppend, %Msg%, sqliteTestQuery.log
			  MsgBox, 0, Query failed, %Msg%
		}
		

	}db.EndTransaction()
}



ArrayToGuiString(items , bSelectFirst){
	str := ""
	for each, item in items
		str .= item "|" ((bSelectFirst && A_Index == 1) ? "|" : "")
	return str
}
