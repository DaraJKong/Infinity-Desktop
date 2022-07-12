/*------------------------------------------*\
|*     OPERATIONS AND DATA MANIPULATION     *|
\*------------------------------------------*/

SortArray(arr, compareFunction) {
	If (arr.Length <= 1) {
		Return arr
	}
	
	If (arr.Length > 1) {
		left := []
		pivot := [arr[1]]
		right := []
		
		arr.RemoveAt(1)
		
		For (item in arr) {
			offset := compareFunction(pivot[1], item)
			
			If (offset > 0) {
				right.Push(item)
			} Else {
				left.Push(item)
			}
		}
		
		(left := %A_ThisFunc%(left, compareFunction)).Push(pivot*)
		left.Push(%A_ThisFunc%(right, compareFunction)*)
		
		Return left
	}
}

HasVal(haystack, needle) {
	If (!IsObject(haystack) || haystack.Length == 0) {
		Return 0
	}
	
	For (index, value in haystack) {
		If (value == needle) {
			Return index
		}
	}
	
	Return 0
}

Dist(pos1, pos2) {
	Return Sqrt(Abs(Integer(pos2[1]) - Integer(pos1[1])) ^ 2 + Abs(Integer(pos2[2]) - Integer(pos1[2])) ^ 2)
}

Join(separator, params*) {
	If (params.Length == 0) {
		Return ""
	}
	
	For (index, param in params) {
		str .= param . separator
	}
	
	Return SubStr(str, 1, -StrLen(separator))
}

/*---------------------------------------*\
|*     ACTIONS AND EXTERNAL COMMANDS     *|
\*---------------------------------------*/

DisableSystemSound(name) {
	RegWrite("", "REG_SZ", "HKCU\AppEvents\Schemes\Apps\.Default\" name "\.Current")
}

RestoreSystemSound(name) {
	Scheme := RegRead("HKCU\AppEvents\Schemes")
	SoundPath := RegRead("HKCU\AppEvents\Schemes\Apps\.Default\" name "\" Scheme)
	RegWrite(SoundPath, "REG_SZ", "HKCU\AppEvents\Schemes\Apps\.Default\" name "\.Current")
}