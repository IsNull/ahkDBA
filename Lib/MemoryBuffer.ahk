
/*
* Abstraction of basic buffer memory handling
*
*/
class MemoryBuffer
{
	Adress := 0
	Size := 0
	
	/*
	* Create a new Buffer from the existing Memory source
	*/
	Create(srcPtr, size)
	{
		this.Adress := this.AllocMemory(size)
		this.memcpy(this.Adress, srcPtr, size)
		this.Size := size
	}
	
	/*
	* Load the file and store it in a binary buffer
	*/
	CreateFormFile(filePath){
		
		if(!FileExist(filePath))
			throw Exception("File must exist and be readable!")
		
		binFile := FileOpen(filePath, "r")
		this.Adress := this.AllocMemory(binFile.Length)
		this.Size := binFile.RawRead(this.Adress+0, binFile.Length)
		
		binFile.Close()
	}
	
	GetPtr(){
		return this.Adress
	}
	
	/*
	* Write the binary buffer to a file
	*/
	WriteToFile(filePath){
		binFile := FileOpen(filePath, "rw")
		binFile.RawWrite(this.Adress+0, this.Size)
		binFile.Close()
	}
	
	/*
	* Free this Buffer, releases the reserved memory
	*/
	Free(){
		static MEM_RELEASE := 0x8000

		ret := DllCall("VirtualFree"
					,Ptr, this.Adress
					,Int, 0
					,Int, MEM_RELEASE)
		this.Adress := 0
		this.Size := 0
		
		return ret
	}
	

	
	ToString(){
		return "MemoryBuffer: @ " this.GetPtr() " size: " this.Size " bytes"
	}
	

	memcpy(dst, src, cnt) {
		return DllCall("MSVCRT\memcpy"
						, Ptr, dst
						, Ptr, src
						, uInt, cnt)
	}
	

	
	/*
	* Allocates the requested size of memory
	* returns the base adress of the new reserved memory
	*/
	AllocMemory(size){
		static MEM_COMMIT := 0x00001000
		static MEM_RESERVE := 0x00002000
		static PAGE_READWRITE := 0x04

		baseAdress := DllCall("VirtualAlloc"
						, Ptr, 0
						, Int, size
						, UInt, MEM_COMMIT | MEM_RESERVE
						, UInt, PAGE_READWRITE, "Ptr") ; don't allow execution in this memory
		return baseAdress
	}
	

	
}


