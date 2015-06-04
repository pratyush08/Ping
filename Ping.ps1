 #$dt = Get-Date -Format D
#New-Label -VisualStyle 'MediumText' "$dt" -FontSize 25  -Foreground black -background white 


#New-Label -VisualStyle 'LargeText' "$a Server is Down" -Foreground red -Background yellow -Show


$var= @()
$pso= @()

Get-Content file.txt | ForEach-Object{
    $var += $_ -split '='
 
    
}


$IP = @()
$name  = @()
$running = @()
$outage = @()

$length_ = $var.Length

#$length_

$i=0;
while($i -lt $length_)
{
    $name += $var[$i]
    $i++
    $i++

}



$i=1;
while($i -lt $length_)
{
    $IP += $var[$i]
    $i++
    $i++
   

} 


$ping_value =@{}

$last_ping_time=@{}


$length_ip = $IP.Length

$i=0

foreach ($element in $IP)
{
  $ping_value.Add($element,0)
  $last_ping_time.Add($element,0)
}












#function to display initial Outage
function showdetail ($a) 
{
    $getEventInput = StackPanel -ControlName 'Error' {
        New-Label -VisualStyle 'LargeText' "$a is Down " -Foreground red -Background yellow -FontWeight Bold             
        New-Button "OK" -On_Click {            
                   
            Close-Control            
    }            
    }-Show
   
} 



function showDetailUP ($b)
{
     $getEventInput = StackPanel -ControlName 'Network' {
        New-Label -VisualStyle 'LargeText' "$b is Running" -Foreground green -Background yellow -FontWeight Bold           
        New-Button "OK" -On_Click {            
                   
            Close-Control            
    }            
    }-Show
    
}



function getNameforIP ($temp_ip)
{
    $index =0
    foreach ($element in $IP)
    {
        if($element -eq $temp_ip)
        {
            break
        }
        $index++
    }
    return $name[$index]
}









#function to display initial states of servers
function showInititalState ($running, $outage)
{
    $getEventInput = StackPanel -ControlName 'Network' {

        $dt = Get-Date -Format D
        Label -VisualStyle 'MediumText' "$dt" -FontSize 17  -Foreground black -background white -FontWeight Bold -HorizontalContentAlignment Center

        Label -VisualStyle 'MediumText' "Running" -FontSize 17 -Foreground Green -Background yellow -FontWeight Bold -HorizontalContentAlignment Center


        Grid -Rows "*","Auto"-Margin 5 {
        UniformGrid -Margin 5 -Columns 5 {
        foreach($element in $running)
        {
        Label -VisualStyle 'MediumText' "$element" -Foreground white -Background green -FontWeight Bold
        }
        }
        }




        Label -VisualStyle 'MediumText' "Stopped" -FontSize 17 -Foreground Red -Background yellow -FontWeight Bold -HorizontalContentAlignment Center
        Grid -Rows "*","Auto"-Margin 5 {
        UniformGrid -Margin 5 -Columns 5 {
         foreach($element in $outage)
        {
        Label -VisualStyle 'MediumText' "$element is Down" -Foreground white -Background red -FontWeight Bold
        }
        }
        }
    
        New-Button "OK" -On_Click {            
                   
            Close-Control            
    }  
            
    }-Show 
     
}   





#initialize running and outage
foreach ($element in $IP)
{
    if(Test-Connection $element -Count 1 -ea SilentlyContinue)
    {
        $running += $element
    }
    else
    {
        $outage += $element
    }
    


}


$index=0
$running_name = @()

foreach ($element in $running)
{
  $index = 0
  foreach($sub_element in $IP)
  {
    if($sub_element -eq  $element)
    {
        break

    }
    $index++
  }
  $running_name += $name[$index]
}



$index=0
$outage_name = @()

foreach ($element in $outage)
{
  $index = 0
  foreach($sub_element in $IP)
  {
    if($sub_element -eq  $element)
    {
        break

    }
    $index++
  }
  $outage_name += $name[$index]
}
showInititalState $running_name $outage_name



do
{

 foreach ($a in $running)
    {
         
      
         if(Test-Connection $a -Count 1 -ea SilentlyContinue)
         {
            
         }
         else
         {
  
             
             $temp_name  = getNameforIP $a 
             $ping_value.set_Item($a,++($ping_value.get_Item($a)))

             if($ping_value.get_Item($a) -gt 5)
             {
                 $running = $running | Where-Object { $_ -ne $a }
         
            
                If ( -not ($outage -contains $a))
                {
                  $outage += $a   
               
             }
                $temp  = $ping_value.get_Item($a)
                $ping_value.set_Item($a,0)
                showDetail $temp_name 

             }
               

           
         }
 
 
   }

   $running = $running | Get-Unique
   
    
  

  
    foreach($element_outage in $outage)
    {
        
         if(Test-Connection $element_outage -Count 1 -ea SilentlyContinue)
         {
            $running +=$element_outage
            $outage = $outage | Where-Object { $_ -ne $element_outage}
            $temp_out  = getNameforIP $element_outage
            showDetailUP $temp_out
         }
         
    }
    Start-Sleep -Seconds 10
    
}while(1)

