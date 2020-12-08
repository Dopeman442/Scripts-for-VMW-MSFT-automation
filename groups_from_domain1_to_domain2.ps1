$domain1group = "groupname1"
$domain2group = "groupname2"
$members  = Get-ADGroupMember $domain1group -Server server.domain1.com
foreach ($member in $members) 
    {
    if ($member.objectClass -eq 'group') 
        {
        $members2  = Get-ADGroupMember $member
        foreach ($member2 in $members2) 
            {
            if ($member2.objectClass -eq 'group') 
                {
                $members3  = Get-ADGroupMember $member2
                foreach ($member3 in $members3) 
                    {
                    if ($member3.objectClass -eq 'group') 
                        {
                        echo $member3.name
                        echo $member3.objectClass
                        echo 3
                        }
                    else 
                        {
                        $membername3 = $member3.name
                        $domain2user3 = get-aduser -filter "(name -eq '$membername3')"
                        $domain2user3
                        Add-ADGroupMember -Identity "$domain2group" -Members "domain2user3"
                        $domain2user3 = $null
                        }
                    }
                }
            else 
                {
                $membername2 = $member2.name
                $domain2user2 = get-aduser -filter "(name -eq '$membername2')"
                $domain2user2
                Add-ADGroupMember -Identity "$domain2group" -Members "$domain2user2"
                $domain2user2 = $null
                }
            }
        }
    else
        {
        $domain2user = $member.name
        $domain2user = get-aduser -filter "(name -eq '$membername')"
        $domain2user
        Add-ADGroupMember -Identity "$domain2group" -Members "$domain2user"
        $domain2group = $null
        }
    }
