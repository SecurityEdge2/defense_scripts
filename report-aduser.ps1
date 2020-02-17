function report-adusers
{


	$users = get-aduser -filter *

	$users = Foreach ($ADUser in $users) {
	$UserInfo = [Ordered] @{}
	$UserInfo.SamAccountname = $ADUser.SamAccountName
	$Userinfo.DisplayName = $ADUser.DisplayName
	$UserInfo.Office = $ADUser.Office
	$Userinfo.Enabled = $ADUser.Enabled
	$userinfo.LastLogonDate = $ADUser.LastLogonDate
	$UserInfo.ProfilePath = $ADUser.ProfilePath
	$Userinfo.ScriptPath = $ADUser.ScriptPath
	$UserInfo.BadPWDCount = $ADUser.badPwdCount
	New-Object -TypeName PSObject -Property $UserInfo
	} 
	$users |ft |out-string

	"**disabled users" |out-string
	$users | Where-Object {$_.Enabled -NE $true} | Format-Table -Property SamAccountName, Displayname


	"`n*** Users Not logged in since $OneWeekAgo`n" 	
	$OneWeekAgo = (Get-Date).AddDays(-7)
	$users |Where-Object {$_.Enabled -and $_.LastLogonDate -le $OneWeekAgo} | Sort-Object -Property LastlogonDate |Format-Table -Property SamAccountName,lastlogondate |out-string

	"`n*** High Number of Bad Password Attempts`n"
	$users | Where-Object BadPwdCount -ge 5 | Format-Table -Property SamAccountName, BadPwdCount | Out-String

	"`n*** Privileged User Report`n"
    $groups = get-adgroup -filter *
    $pu = @()
    $groups | %{ $group_name = $_.Name; $pu +=  Get-ADGroupMember -Identity $group_name  -Recursive | select @{Name='Group';expression={$group_name }}, Name,whenCreated, LastlogonDate }
    $pu | Sort-Object -Property Group |ft |out-string

    "*** Machines not logged on in past month`n"
    $AMonthAgo = (Get-Date).AddMonths(-1)
    $old_pc = Get-ADComputer -Filter 'lastLogonDate -lt  $AMonthAgo'  
    $old_pc | Format-Table -Property Name, LastLogonDate | Out-String

    "*** Users not logged on in past month and enabled`n"
    $old_users = get-aduser -filter 'lastLogonDate -lt  $AMonthAgo -and Enabled -eq $true' 
    $old_users | Format-Table -Property Name, LastLogonTimestamp | Out-String


    #problem with lastlogondate, LastLogonTimestamp (replecatable)
    #https://docs.microsoft.com/ru-ru/archive/blogs/askds/the-lastlogontimestamp-attribute-what-it-was-designed-for-and-how-it-works 
    #use ELK
}
 report-adusers > report.txt

