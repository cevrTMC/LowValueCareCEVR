

function split_file{
    param (
        [string]$filePath,
        [int]$linesPerFile
    )
    $file = Get-Item -Path $filePath
    $reader = New-Object System.IO.StreamReader($file.FullName, [System.Text.Encoding]::UTF8)
   
    $i=1
    $counter=0
    $pathAndFilename = $file.FullName.Replace('.', '_'+$i.ToString() + '.') 
    $streamout = new-object System.IO.StreamWriter $pathAndFileName   
    try {
    for ( $line = $reader.ReadLine(); ($line -ne $null); $line = $reader.ReadLine() ) 
    { 
        $streamout.writeline($line)
        $counter+=1
        if ($counter -eq $linesPerFile)
        {   
            $counter =0
	    $streamout.Close()
	    $i++ 
            $pathAndFilename = $file.FullName.Replace('.', '_'+$i.ToString() + '.')
            $streamout = new-object System.IO.StreamWriter $pathAndFilename	    
        }
    }
    }
    finally {
       $reader.Close()
       $streamOut.close()
    }
}


function min_max_claim{
   param(
	[string]$claimFile
   )    
   $file = Get-Item -Path $claimFile
   $reader = New-Object System.IO.StreamReader($file.FullName, [System.Text.Encoding]::UTF8)
   $min_num = 999999999999
   $max_num = -1
   for ( $line = $reader.ReadLine(); ($line -ne $null); $line = $reader.ReadLine() ) 
   { 	        
      $value=($line -split ",")[1]
      if([long]$value -le $min_num) {
         $min_num = $value
      }
      if([long]$value -ge $max_num) {
	$max_num = $value 
      }
   }
   $reader.Close()
   return [string]$min_num, [string]$max_num
}


function split_rev{
	param(	 
	 [string]$claimFileBase,
     [string]$lineFile
    )
	$chunk = 1
	$inputClaimFile = $claimFileBase.Replace('.', '_'+$chunk.ToString() + '.')

	$file = Get-Item -Path $lineFile
	$reader = New-Object System.IO.StreamReader($file.FullName, [System.Text.Encoding]::UTF8)
	$pathAndFilename = $file.FullName.Replace('.', '_'+$chunk.ToString() + '.')
	$streamout = new-object System.IO.StreamWriter $pathAndFilename	
		
	$idrange= min_max_claim -claimFile $inputClaimFile
	$min_claim_id = [long]$idrange[0]
	$max_claim_id = [long]$idrange[1]

	Write-Host $chunk
	Write-Host $inputClaimFile $pathAndFileName
	Write-Host [string]$min_claim_id [string]$max_claim_id

	for ( $line = $reader.ReadLine(); ($line -ne $null); $line = $reader.ReadLine() ) 
	{ 	        
		$value=($line -split ",")[1]
		if(([long]$value -ge $min_claim_id) -and ([long]$value -le $max_claim_id)) {
			$streamout.writeline($line)
		}else{
			$streamout.Close()
			$chunk++
			$inputClaimFile = $claimFileBase.Replace('.', '_'+$chunk.ToString() + '.')
			$pathAndFilename = $file.FullName.Replace('.', '_'+$chunk.ToString() + '.')
			$streamout = new-object System.IO.StreamWriter $pathAndFilename
			$idrange= min_max_claim -claimFile $inputClaimFile
			$min_claim_id = [long]$idrange[0]
			$max_claim_id = [long]$idrange[1]
			Write-Host $chunk
			Write-Host $inputClaimFile $pathAndFileName
			Write-Host [string]$min_claim_id [string]$max_claim_id
			$streamout.writeline($line)
		}
	}
	$streamout.Close()   
	$reader.Close()	
}


$f_claim = "inp_claimsk_lds_100_2017.csv"
$f_rev = "inp_revenuek_lds_100_2017.csv"

split_file -filePath $f_claim -linesPerFile 1000000

split_rev -claimFileBase $f_claim -lineFile $f_rev