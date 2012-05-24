#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



class ADO
{
	class CursorType
	{
		static adOpenUnspecified := -1
		static adOpenForwardOnly := 0
		static adOpenKeyset := 1
		static adOpenDynamic := 2
		static adOpenStatic := 3
	}
	
	class LockType
	{
		static adLockUnspecified := -1
		static adLockReadOnly := 1
		static adLockPessimistic := 2
		static adLockOptimistic := 3
		static adLockBatchOptimistic := 4
	}
	
	class CommandType
	{
		static adCmdUnspecified := -1
		static adCmdText := 1
		static adCmdTable := 2
		static adCmdStoredProc := 4
		static adCmdUnknown := 8
		static adCmdFile := 256
		static adCmdTableDirect := 512
	}
	
	class AffectEnum
	{
		static adAffectCurrent := 1
		static adAffectGroup := 2
	}	

}