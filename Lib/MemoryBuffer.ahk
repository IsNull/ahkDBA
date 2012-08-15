
/*
* Abstraction of basic buffer memory handling
*
*/
class MemoryBuffer
{
	static MEM_RELEASE := 0x8000
	static MEM_COMMIT := 0x00001000
	static MEM_RESERVE := 0x00002000
	static PAGE_READWRITE := 0x04
		
	Adress := 0
	Size := 0
	
	
	
	
	
	ToBase64(){
		static CryptBinaryToString := "Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A")
		static CRYPT_STRING_BASE64 := 0x00000001

		num := 0

		DllCall("Crypt32.dll\CryptBinaryToString"
				, Ptr,  this.Adress
				, Uint, this.Size
				, Uint, CRYPT_STRING_BASE64
				, Str, encoded
				, Uint*, num)
				
		return encoded
	}
	
	
	
	
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
	*
	* returns true on succes, otherwise false
	*/
	WriteToFile(filePath){
		binFile := FileOpen(filePath, "rw")
		bytesWritten := binFile.RawWrite(this.Adress+0, this.Size)
		binFile.Close()
		return (bytesWritten == this.Size) ; we expect that all bytes were written down
	}
	
	/*
	* Free this Buffer, releases the reserved memory
	*/
	Free(){
		ret := DllCall("VirtualFree"
					,Ptr, this.Adress
					,Int, 0
					,Int, this.MEM_RELEASE)
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
		baseAdress := DllCall("VirtualAlloc"
						, Ptr, 0
						, Int, size
						, UInt, this.MEM_COMMIT | this.MEM_RESERVE
						, UInt, this.PAGE_READWRITE, "Ptr") ; don't allow execution in this memory
		return baseAdress
	}

}


