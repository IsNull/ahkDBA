/**************************************
	base classes
***************************************
*/

global null := 0	; for better readability

/*
	Check for same (base) Type
*/
is(obj, type){
	
	if(IsObject(type))
		type := typeof(type)
	
	while(IsObject(obj)){
		
		if(obj.__Class == type){
			return true
		}
		obj := obj.base
	}
	return false
}

/*
* Returns the type of the given Object
*/
typeof(obj){
	if(IsObject(obj)){
		cls := obj.__Class
		
		if(cls != "")
			return cls
		
		while(IsObject(obj)){
			if(obj.__Class != ""){
				return obj.__Class
			}
			obj := obj.base
		}
		return "Object"
	}
	return "NonObject"
}

inheritancePath( obj ){
	itree := []

	if(IsObject(obj)){
		
		ipath := "inheritance tree:`n`n"  
		
		while(IsObject(obj := obj.base)){
			itree[A_index] := (Trim(obj.__Class) != "") ? obj.__Class : "{}"
		}
		cnt := itree.MaxIndex()
		for i,cls in itree
		{
			j := cnt - (i - 1)
			ipath .= itree[j]	
			
			if(i < cnt)
			{
				ipath .= "`n"
				loop % i
					ipath .= "   " 
				ipath .= ">"
			}
		}
	}else
		ipath := "NonObject"
		
	return ipath
}


IsObjectMember(obj, memberStr){
	if(IsObject(obj)){
		return ObjHasKey(obj, memberStr) || IsMetaProperty(memberStr)
	}
}


IsMetaProperty(str){
	static metaProps := "__New,__Get,__Set,__Class"
	if str in %metaProps%
		return true
	else
		return false
}


/**
* Provides some common used Exception Templates
*
*/
class Exceptions
{
	NotImplemented(name=""){
		return Exception("A not implemented Method was called." (name != "" ? ": " name : "") ,-1)
	}
	
	MustOverride(name=""){
		return Exception("This Method must be overriden" (name != "" ? ": " name : "")  ,-1)
	}
	
	ArgumentException(furtherInfo=""){
		return Exception("A wrong Argument has been passed to this Method`n" furtherInfo,-1)
	}
}




;Base
{
	"".base.__Call := "Default__Warn"
	"".base.__Set  := "Default__Warn"
	"".base.__Get  := "Default__Warn"

	Default__Warn(nonobj, p1="", p2="", p3="", p4="")
	{
		ListLines
		MsgBox A non-object value was improperly invoked.`n`nSpecifically: %nonobj%
	}
}