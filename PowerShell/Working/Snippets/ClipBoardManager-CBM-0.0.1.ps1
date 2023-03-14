<#
Messagebox Example
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show('Masked Items Reset', 'Info', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)


To run - Put this in your run line 
powershell -noexit C:\Users\XXXXXXXXXXX\Documents\FileName.ps1
Select enter

    .SYNOPSIS
        UI that will display the history of clipboard items

    .DESCRIPTION
        UI that will display the history of clipboard items. Options include filtering for text by
        typing into the filter textbox, context menu for removing and copying text as well as a menu to 
        clear all entries in the clipboard and clipboard history viewer.

        Use keyboard shortcuts to run common commands:

        Ctrl + C -> Copy selected text from viewer
        Ctrl + R -> Remove selected text from viewer
        Ctrl + E -> Exit the clipboard viewer

    .NOTES
        Author: Boe Prox
        Created: 10 July 2014
        Version History:
            1.0 - Boe Prox - 10 July 2014
                -Initial Version
            1.1 - Boe Prox - 24 July 2014
                -Moved Filter from timer to TextChanged Event
                -Add capability to select multiple items to remove or add to clipboard
                -Able to now use mouse scroll wheel to scroll when over listbox
                - Added Keyboard shortcuts for common operations (copy, remove and exit)

            1.7.5-04 # 1/14/23
                Thinking about adding right click function to open selected item with notepad

            0.0.1 # 3/13/2023 (Duane) (Main objective was quick development of features)
                To many changes to account for
                -Tools
                --Pause
                --Titel Windows (Open multipl windows, label each one, pause / un pause as needed)
                --Add time stamp to items                                              
                --Stay On top
                
                Windows Options
                -- GPT Options
                -- Reset Masked Selections
                --
                --items I'd like to see developed
                -- Auto scroll to bottom of list box with new items
                -- Window flashes as new items come in / no flash when paused
                -- 

                
#>

##Requires -Version 3.0
$Runspacehash = [hashtable]::Synchronized(@{})
$Runspacehash.Host = $Host
$Runspacehash.runspace = [RunspaceFactory]::CreateRunspace()
$Runspacehash.runspace.ApartmentState = "STA"
$Runspacehash.runspace.Open()
$Runspacehash.runspace.SessionStateProxy.SetVariable("Runspacehash",$Runspacehash)
$Runspacehash.PowerShell = {Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase}.GetPowerShell()

$Runspacehash.PowerShell.Runspace = $Runspacehash.runspace
$Runspacehash.Handle = $Runspacehash.PowerShell.AddScript({
    Function Get-ClipBoard {
        [Windows.Clipboard]::GetText()
    }
Function Set-ClipBoard {
        $Script:CopiedText = @"
$($listbox.SelectedItems | Out-String) 
"@
        [Windows.Clipboard]::SetText($Script:CopiedText)
                
    }
    
Function Clear-Viewer {
        [void]$Script:ObservableCollection.Clear()
        [Windows.Clipboard]::Clear()
        
    }
    
    #Build the GUI
    [xml]$xaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="ClipBoardManager-CBM-0.0.1" WindowStartupLocation = "CenterScreen" 
        Width = "370" Height = "425" ShowInTaskbar = "True" Background = "White">
        <Grid >
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto" />
                <RowDefinition Height="Auto" />
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Grid.Resources>
                <Style x:Key="AlternatingRowStyle" TargetType="{x:Type Control}" >
                    <Setter Property="Background" Value="LightGray"/>
                    <Setter Property="Foreground" Value="Black"/>
                    <Style.Triggers>
                        <Trigger Property="ItemsControl.AlternationIndex" Value="1">
                            <Setter Property="Background" Value="White"/>
                            <Setter Property="Foreground" Value="Black"/>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </Grid.Resources>
            <Menu Width = 'Auto' HorizontalAlignment = 'Stretch' Grid.Row = '0'>
                <Menu.Background>
                    <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                        <LinearGradientBrush.GradientStops> 
                        <GradientStop Color='#C4CBD8' Offset='0' /> 
                        <GradientStop Color='#E6EAF5' Offset='0.2' /> 
                        <GradientStop Color='#CFD7E2' Offset='0.9' /> 
                        <GradientStop Color='#C4CBD8' Offset='1' /> 
                        </LinearGradientBrush.GradientStops>
                    </LinearGradientBrush>
                </Menu.Background>
                <MenuItem x:Name = 'FileMenu' Header = '_Tools'>
                    <MenuItem x:Name = 'Clear_Menu' Header = '_Clear' />
                    <MenuItem x:Name = 'Save_Menu'  Header = '_Save As File'/>
                    <MenuItem x:Name = 'Import_Menu'  Header = '_Import File'/>
                    <MenuItem x:Name = 'ZZZ' Header = '_------------------------' IsCheckable="false"/>
                    <MenuItem x:Name = 'Title_Window'  Header = '_Title Window'/>
                    <MenuItem x:Name = 'StayTop_Menu' Header = '_Stay On Top' IsCheckable="true"/>
                    <MenuItem x:Name = 'AddTime_Menu' Header = '_Add Time Stamp' IsCheckable="true"/>
                    <MenuItem x:Name = 'Pause_Menu' Header = '_Pause' IsCheckable="true"/>
                    <MenuItem x:Name = 'ZZ' Header = '_------------------------' IsCheckable="false"/>
                    <MenuItem x:Name = 'Options_Menu' Header = '_Options' IsCheckable="false"/>
                </MenuItem>
            </Menu>
            <GroupBox Header = "Filter"  Grid.Row = '2' Background = "White">
                <TextBox x:Name="InputBox" Height = "25" Grid.Row="2" />
            </GroupBox>
            <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Grid.Row="4" Height = "Auto">                
                <ListBox x:Name="listbox" AlternationCount="2" ItemContainerStyle="{StaticResource AlternatingRowStyle}" SelectionMode='Extended'>                
                    <ListBox.Template>
                        <ControlTemplate TargetType="ListBox">
                            <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderBrush}">
                                <ItemsPresenter/>
                            </Border>
                        </ControlTemplate>
                    </ListBox.Template>
                    <ListBox.ContextMenu>
                        <ContextMenu x:Name = 'ClipboardMenu'>
                        <MenuItem x:Name = 'SelectAll_Menu' Header = 'Select All'/>                                  
                        <MenuItem x:Name = 'Copy_Menu' Header = 'Copy item'/>
                            <MenuItem x:Name = 'Remove_Menu' Header = 'Remove item'/>
                            <MenuItem x:Name = 'zzz' Header = '------------------------'/>
                            <MenuItem x:Name = 'AppendFile_Menu' Header = 'Append Selected items to file'/>
                            <MenuItem x:Name = 'CreateFile_Menu' Header = 'Create file from Selected items'/>
                            <MenuItem x:Name = 'Open_URLs' Header = 'Open Selected URLs'/> 
                            <MenuItem x:Name = 'Open_Google_Search' Header = 'Open Selected in Google'/>
                            <MenuItem x:Name = 'Open_with_NOTEPAD' Header = 'Open Selected in NOTEPAD'/>                                                         
                            <MenuItem x:Name = 'Mask_Selected_Item' Header = 'Mask Selected Item'/>
                            <MenuItem x:Name = 'zzzz' Header = '------------------------'/>
                            <MenuItem x:Name = 'ChatGPT' Header = 'Ask ChatGPT'/>                              
                        </ContextMenu>
                    </ListBox.ContextMenu>
                </ListBox>
            </ScrollViewer>  
            <TextBox x:Name="editBox" Height = "20" Margin = "0, -300, 0, 0" Grid.Row="4" Visibility="hidden"/>
            <TextBox x:Name="indexBox" Height = "10" Grid.Row="5" Visibility="hidden"/>          
        </Grid>
        
    </Window>
"@
 
 # 3/29


    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Window=[Windows.Markup.XamlReader]::Load( $reader )
    
    #Connect to Controls
    $listbox = $Window.FindName('listbox')
    $InputBox = $Window.FindName('InputBox')
    $ItemEdit = $Window.FindName('editBox')
    $indexBox = $Window.FindName('indexBox')
    $Copy_Menu = $Window.FindName('Copy_Menu')
    $Edit_Menu = $Window.FindName('Edit_Menu')
    $Remove_Menu = $Window.FindName('Remove_Menu')
    $Clear_Menu = $Window.FindName('Clear_Menu')

    $Create_File_Selected = $Window.FindName('CreateFile_Menu') 
    $Append_File_Selected = $Window.FindName('AppendFile_Menu') 
    $SelectAll_Menu = $Window.FindName('SelectAll_Menu')
    $Open_URLs = $Window.FindName('Open_URLs') 
    $GoogleSearch = $Window.FindName('Open_Google_Search') 
    $OpenNotepad = $Window.FindName('Open_with_NOTEPAD') 
    $ChatGPT = $Window.FindName('ChatGPT') 
    $MaskSelectedItem = $Window.FindName('Mask_Selected_Item') 
    $Save_Menu = $Window.FindName('Save_Menu')
    $Import_Menu = $Window.FindName('Import_Menu') 
    $Title_Window = $Window.FindName('Title_Window') 
    $StayTop_Menu = $Window.FindName('StayTop_Menu')    
    $AddTime_Menu = $Window.FindName('AddTime_Menu')
    $Pause_Menu = $Window.FindName('Pause_Menu')
    $Options_Menu = $Window.FindName('Options_Menu')

    
$global:chatGPTapiKey = $null 
$global:ChangeGPTAPI = $null
$global:ShortResponse = $null
$global:MediumResponse = $null
$global:CompleteResponse = $null
$global:VocalizeResponse = $null
$global:OpenResponseNotepad = $null
$global:ResetAllSettings = $null 
$global:ChatGPTSelectedItem = $null
$global:HideCopiedItems = $null 
$global:tempVar = $null
$global:OpenWindowsSpeech = $null
$Global:Cancel = $null
$Global:Onload = $null




Add-Type -AssemblyName System.Windows.Forms
    
$Clear_Menu.Add_Click({
    Clear-Viewer
})


$MaskSelectedItem.Add_Click(
{ 

    $applyMask = [System.Windows.MessageBox]::Show("This will mask (Hide) all future like items. Select with caution.`r`rCurrent Like Value:$global:HideCopiedItems", "Reset in Options", "YesNo", "Question")
                
                if ($applyMask -eq "Yes")
                {
                    $global:HideCopiedItems += $listbox.SelectedItems[0]
                }

    
    # Not Working..... Attempting to cycle through all values and mask items found as a LIKE match
    <#
    $applyMask2Items = [System.Windows.MessageBox]::Show("Apply Mask to all items?", "Confirm Action", "YesNo", "Question")
                
                if ($applyMask2Items -eq "Yes")
                {
                    # 
                    #@($listbox.SelectedItems) | ForEach-Object 
                    #@($listbox.items | ForEach-Object)
                    foreach ($item in $listbox.Items)
                    {     

                        #[System.Windows.Forms.MessageBox]::Show('11111111', 'Info', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

                        #if ($_.ToString() -like $listbox.SelectedItems[0]) 
                        if ($item -eq $listbox.SelectedItems[0]) 
                        {
                            #
                            [System.Windows.Forms.MessageBox]::Show('Match Found', 'Info', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

                            
                            
                            $index = $listbox.Items.IndexOf($item)
                            #$listbox.Items.Set($index, "**************")
                            [System.Windows.Forms.MessageBox]::Show("Index:$index", 'Info', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
                             $listbox.Items.set($index, "***************")

                        }
                    }
                }

                #>
    
})

    
$ChatGPT.Add_Click(
{ 

$global:ChatGPTSelectedItem = $listbox.SelectedItems[0]

Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

if(($global:chatGPTapiKey -eq $null) -or ($global:chatGPTapiKey -eq ""))
{

    # 2/21 - Added the API for testing purposes...............................................................................
    $defaultText = "Example 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"
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $global:chatGPTapiKey = [Microsoft.VisualBasic.Interaction]::InputBox("Insert your CHATGPT API code. This is not saved and will be required after restarting everytime.", "Insert your CHATGPT API code", $defaultText)

            If ((($global:chatGPTapiKey -eq "Cancel") -or ($global:chatGPTapiKey -eq "") -or ($global:chatGPTapiKey -eq $null)))
            {
    
                [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
                [System.Windows.Forms.MessageBox]::Show('A value must exist - Please provide API key.', 'Info-21PPPPPP76', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
                                
                return
            }
        }



 # Creates listbox to right click and execute command via watching the clipboard (This is a Chat Settings dialogbox and App config dialogbox = "Coming Soon")
 Add-Type -AssemblyName PresentationFramework

 $WindowChat = New-Object System.Windows.Window
 $WindowChat.SizeGripStyle = "Hide"
 $WindowChat.MaximizeBox = $false
 $WindowChat.WindowStartupLocation = "CenterScreen" #3/9
 $WindowChat.Topmost = $true
 $WindowChat.Title = "ChatGPT Settings Dialogbox" 
 $WindowChat.Width = 425
 $WindowChat.Height = 500

$Label = New-Object System.Windows.Controls.Label
$Label.Content = "Right click and copy the setting you wish to set. `r`r Note: These settings can be adjusted in TOOLS - Options `r Right Click ChatGPT Options"
$Label.Margin = New-Object System.Windows.Thickness(10)
 
 $listboxChatGPT = New-Object System.Windows.Controls.ListBox
 $listboxChatGPT.Width = 300
 $listboxChatGPT.Height = 200
 $listboxChatGPT.Margin = New-Object System.Windows.Thickness(10)
 $listboxChatGPT.ItemsSource = @("ChatGPT Short Response", "ChatGPT Medium Response", "ChatGPT Complete Response", "ChatGPT Open Response Notepad" , "ChatGPT Vocalize Response", "Open Windows Speech Settings","ChatGPT Reset All Settings")
 
  
 $ContextMenu = New-Object System.Windows.Controls.ContextMenu
 $MenuItem = New-Object System.Windows.Controls.MenuItem
 $MenuItem.Header = "Copy"
 $MenuItem.Add_Click({ # this copy function send text to main listbox, thus global variable is set - If ChatGPT is executed, these var's are evaluated....
     $text = $listboxChatGPT.SelectedItem
     [System.Windows.Clipboard]::SetText($text)
 })
 $ContextMenu.Items.Add($MenuItem)
 $listboxChatGPT.ContextMenu = $ContextMenu
 
 $Button = New-Object System.Windows.Controls.Button
 $Button.Content = "Send to ChatGPT"
 $Button.Margin = New-Object System.Windows.Thickness(10)

 $Button.Add_Click(
{ $WindowChat.Close() })
 

 $ButtonClose = New-Object System.Windows.Controls.Button
 $ButtonClose.Content = "Cancel"
 $ButtonClose.Margin = New-Object System.Windows.Thickness(10)

 $Global:Cancel = $null
 $ButtonClose.Add_Click(
    { 
        $Global:Cancel = "true"
        $WindowChat.Close()
        #return #3/10        
     })


 $Labelb = New-Object System.Windows.Controls.Label
 $Labelb.Content = "Developed by Duane Joseph (2023) / ChrisDee (GitHub 2016))"
 $Labelb.Margin = New-Object System.Windows.Thickness(10)
 
 
 $StackPanel = New-Object System.Windows.Controls.StackPanel
 $StackPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical
 $StackPanel.Margin = New-Object System.Windows.Thickness(10)

$StackPanel.Children.Add($Label)
$StackPanel.Children.Add($listboxChatGPT)
$StackPanel.Children.Add($Button) 
$StackPanel.Children.Add($ButtonClose) # 
$StackPanel.Children.Add($Labelb)
$WindowChat.Content = $StackPanel
$WindowChat.ShowDialog() | Out-Null

        If ((($global:chatGPTapiKey -eq "Cancel") -or ($global:chatGPTapiKey -eq "") -or ($global:chatGPTapiKey -eq $null)))
        {
            [System.Windows.Forms.MessageBox]::Show('Cancel Selected or Something went wrong. Try resetting ChatGPT settings, enter a valid API key and try again.', 'Info-8799AAAAA8', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

        }else
        {

        [string] $prompt
        [string] $model = "text-davinci-003"
        [int] $responses = 1
        [int] $length = 2048
        $rawPrompt = "in one sentence " + $listbox.SelectedItems[0]

        }



# Set the ChatGPT output / response length (Add like a 3,4,5 grader, or summary, or ?????????)
  if ($global:ShortResponse -eq "ChatGPT Short Response") 
  {      $rawPrompt = "in one sentence " + $listbox.SelectedItems[0] }
      
  if ($global:MediumResponse -eq "ChatGPT Medium Response") 
  {     $rawPrompt = "in one paragraph sentence " + $listbox.SelectedItems[0] }
  
  if ($global:CompleteResponse -eq "ChatGPT Complete Response") 
  { $rawPrompt = $listbox.SelectedItems[0] }
  
        try{
        
        $body = @{
            model = $model
            prompt = $rawPrompt
            n = $responses
            max_tokens = $length
        } | ConvertTo-Json



        # Cancel - Stop sending API web request. 3/10
        if ($Global:Cancel -ne $true) 
        {
            # Go Live - resend request to ChatGPT ********************************** 
            $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/completions" -Method "POST" -Body $body -Headers @{ "Authorization" = "Bearer $global:chatGPTapiKey" } -ContentType "application/json"
            # 
            #[string] $output = "Manuel response provided" #$response[0].choices[0].text
            # - PROD  
        }else{

            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('Cancel Selected or Something went wrong. Try resetting ChatGPT settings, enter a valid API key and try again.', 'Info-879999977778', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
            $Global:Cancel = $null
            return
        }

        }catch
        {
            
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('Cancel Selected or Something went wrong. Try resetting ChatGPT settings, enter a valid API key and try again.', 'Info-8777778', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

            return
            
        }


[string] $output = $response[0].choices[0].text
Start-Sleep -s 2


        # output / response sent to localhost Text to speech engine
        if (($output -ne $null) -or ($output -ne " "))
        {
                try 
                {
                        if ($global:VocalizeResponse -eq "ChatGPT Vocalize Response") 
                        { 
                            $speak.Speak($output)
                        }

                }
                catch {                        
                    #3/10 error[Microsoft.VisualBasic.Interaction]::InputBox("Error have occurred:", "Error:38392", $_.Error)                                
                    #Add-Type -AssemblyName System.Windows.Forms
                    #[System.Windows.Forms.MessageBox]::Show('Something went wrong. Try resetting ChatGPT settings, enter a valid API key and try again.', 'Info-88888928', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
                    return
                }
        

}



[Windows.Clipboard]::SetText($global:ChatGPTSelectedItem + "`r" + $output)



    if ($global:OpenResponseNotepad -eq "ChatGPT Open Response Notepad") 
            {

                Add-Type -AssemblyName PresentationFramework
                $OpenNotePadQuestion = [System.Windows.MessageBox]::Show("Ready to capture ChatGPT response into a text file?", "Confirm Action", "YesNo", "Question")
                
                if ($OpenNotePadQuestion -eq "Yes") 
                {
                                    $notepad = New-Object -ComObject "WScript.Shell"
                                    
                                    $notepad.run("notepad.exe")
                                    Start-Sleep -s 3
                                    [Windows.Forms.SendKeys]::SendWait("^v")
                    
                } else 
                {
                    return        
                }
    }
    

   }) 

    $OpenNotepad.Add_Click({ 
        
        #
        Add-Type -AssemblyName System.Windows.Forms
        
        @($listbox.SelectedItems) | ForEach-Object #Ozzy
        {     
            if ($_.ToString() -like "System.Windows.Controls.ListBox") 
            {
                
            }else
            {
               $notepad_data += $_ 
            }

        }
            Set-ClipBoard = $notepad_data
            $notepad = New-Object -ComObject "WScript.Shell"
            $notepad.run("notepad.exe")
            Start-Sleep -s 2
            [Windows.Forms.SendKeys]::SendWait("^v")
    })




    $Open_URLs.Add_Click({ #

        @($listbox.SelectedItems) | ForEach-Object {     
            
            $urlExecute = $_
            Start-Process $urlExecute
            Start-Sleep -Seconds 3
        }

    })

    $SelectAll_Menu.Add_Click({ 
        $listbox.SelectAll()
    })

    $GoogleSearch.Add_Click({ 
        
        #https://www.google.com/search?q=flags

        @($listbox.SelectedItems) | ForEach-Object {     

            $gSearchVar = $_
            $gSearchVar = $gSearchVar -replace " ","%20"
            
            $google = New-Object -ComObject "WScript.Shell"
            $google.Run("https://www.google.com/search?q=$gSearchVar")

        }
        
    })

    


    $Append_File_Selected.Add_Click({
        
        #1/31
    
        $Dialog = New-Object System.Windows.Forms.SaveFileDialog
        
        $NameFilter = "Text Files (*.txt)|*.txt"
        
        $Dialog.Filter = $NameFilter
        
        if($Dialog.ShowDialog() -eq 'Ok'){
        
             @($listbox.SelectedItems) | ForEach-Object {     
                
                $save_data = $_ #+ "`n" 
                $save_data | Out-File $Dialog.FileName -Append
            }
        }
      
    })



    
    $Create_File_Selected.Add_Click({
    
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $Dialog = New-Object System.Windows.Forms.SaveFileDialog
        $NameFilter = "Text Files (*.txt)|*.txt"
    
        $Dialog.Filter = $NameFilter
        
        if($Dialog.ShowDialog() -eq 'Ok'){
        
            @($listbox.SelectedItems) | ForEach-Object { # 
        
                $save_data += $_ + "`n" 
                $save_data | Out-File $Dialog.FileName

            }

        }
    })



    
    



    $Edit_Menu.Add_Click({
        $pos = $listbox.SelectedIndex;
        $indexBox.Text = $pos
        
        $ItemEdit.Text = $listbox.SelectedItems[0]
        $ItemEdit.Visibility = "visible"
        $marginText = "0, " + ($pos * 40 - 300) + ", 0, 0"
        $ItemEdit.Margin = $marginText
        $ItemEdit.Focus()
    })

    $Remove_Menu.Add_Click({
        @($listbox.SelectedItems) | ForEach-Object {
            [void]$Script:ObservableCollection.Remove($_)
            
        }
    })
    
    $Copy_Menu.Add_Click({
        Set-ClipBoard        
    })
    
    $Save_Menu.Add_Click({
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null #
        $Dialog = New-Object System.Windows.Forms.SaveFileDialog
        $NameFilter = "Text Files (*.txt)|*.txt"
        $Dialog.Filter = $NameFilter
        
        if($Dialog.ShowDialog() -eq 'Ok'){
            $save_data = $listbox.Items
            $save_data | Out-File $Dialog.FileName
        }
        
    })


$Title_Window.Add_Click({ # 


    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $global:tempVar = [Microsoft.VisualBasic.Interaction]::InputBox("Type the new Window Title.", "Informational", "Informational")


            If ((($global:tempVar -ne "Cancel") -or ($global:tempVar -ne "") -or ($global:tempVar -ne $null)))
            {
                $Window.Title = $global:tempVar
            }
})

    
    $Import_Menu.Add_Click({ # 
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $NameFilter = "Text Files (*.txt)|*.txt"
        $Dialog.Filter = $NameFilter
        
        if($Dialog.ShowDialog() -eq 'Ok'){
        
            Clear-Viewer
        
            Get-Content $Dialog.FileName | ForEach-Object {
                [void]$Script:ObservableCollection.Add($_)
            }
            
        }
        
    })



    $StayTop_Menu.Add_Click({
        if ($Window.Topmost -eq $True) {
            $Window.Topmost = $False
        } else {
            $Window.Topmost = $True
        }
    })

    


$Options_Menu.Add_Click({

Add-Type -AssemblyName PresentationFramework

$Window = New-Object System.Windows.Window
$Window.Title = "Clipboard Manager Options"
$Window.Width = 400
$Window.Height = 450
$Window.WindowStartupLocation = "CenterScreen"

# Attempt to display encoded images
#----------------------------------------------------------------------------
<#
#add an image to the form using Base64
$base64ImageString = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAT6SURBVFhHvZcPbBNVHMe/1+tdu26l3R+3zmHt2ABF2TTqcNFgNhN0glXUKIbEaCBqjMZoTJyRIDGOhAiJiqKJI5iJGMmUsIyoaEDHIpapiWRjEGBL9rfAtnZr17W93p3v2lfWXu/2Bxc+6Uvf33u/936/+/1+xzy/0yljARAEkdb0MfEcDAYGMXF6roH+/284jp21iJIIIRajKxIsmABzgWGYeEnlugqgxZxtQJYERIUQBCkGSSZLEr+rJE5mAMvy4HkLONVJ9ZhVAFkWEY34EEEuiopWwJFth4k1ko1YJLeQJZnMI4JJYUxODWBwqBs+KQvZWRawGk9niCEmmVEAWSanDoeQ51qPypL7UHXnM6i0W+moNtHQP/D82YRTg7+j43wPjDk2sHQsiYGdqwAREc6KV/FUbT0qLLRzroRPovWXbfju9BkYzfqmpjsiywHwy+qxae01bK5grsa6R3fjMedkQkUpJRXdG2Cjy+F+6SjcebQjlZEWHO5sgy9K6mw+nKXPonaJKzGmItazCRubj8JM24r+U19F9o41tm20ngZ39wG8taKAtqaJXK5Hw6GP0Xb2V3T1d+Dc4Cmc6zuBrqwHUF2Ul6lvI4/Ov1sxTn1AqgEq6KqA6f8Ae4/vwonersRJ40yh4/DX6BwdB8vfgEUWUswWxCbPoLvtRwxJdFoq5nwsV/ZMFhX6RhgLkVePI/47B2bODCPLkdNFERz3QSRuVUEirlWMTSAYChD//hDefecnVGe8JF048mEdDtKWEgtS0TdC1gxOCRxRP8YDQ7ji68XQSC9GI154R/vQd6kPXv8gpOwarH2yBZ++fRD35NDFahiZXH+iqJnVEUnEA04GhjEWIgZjd6C68hXUVTyOpUW3osBspLNmgtzArkfQTFtqdAWQZQmx8AB8Uyyq3L/h9VX3w07H5kcXWndOC6D20LoqkIQRMM4vcaAhhveuefMEBrJLsqjRFEBxwbxjHxqf2wwb7dNDDPehq/t9fLZ3IzwTtHMeaArAyCzq1m+AibbTkEbg7dmDTxrtcG9h4N5+M7Z8vwMn/TxMmk8jECXHA6iGsjWXWKzbsVrrzoULOPZtIV785k10TNhwo6MMzsIyOOzFsLJWGHVsUiZ6V3Sv1r+CtgpcrquuM43RH7Bn2IXFeYthNZH8LvlgOYSw5V4Uai5S5ui/htoCpKUaKWQtwUrOh3AskVQyJAcQImMIiCW47cEaFMZ7M2HIFSSLGk0BDL7LEGg9DdvD2HyXGy5TMO6cxsIRWB3rsHrVbrxRVkwnqSHeUkxeVaYAmn6Awy3Y8PLPqM2mHSouXfwCHq8fMb4Q5eUvoCI388HTnMfxxhrsDxrjoUAU07fTFECSAii+vRFb657AfFMBJelOt8UwLrQvQ8NfBjDx1I12U7RVYLBi+PRWfH6sBT7aNysjX6HpSCOG09N+ghlO19MkjisHy7Qt3XxAxjj6B9rRe+UsgsaluCk/n6hGjYjA0H40t+/AIU8T/ujxoKTqNZSrJrKL1qB0/CN4RmlHCjMGI5lkuVEhCi67FAXWXGQpIZkakpIti1IIU5MD8E6MQWCyYeFkWGwrUWhKVwJv4iEH/8VFf+ZWs0ZDJSiJ4lT8k0oi9enJSoZjIBmuGSaj4hMSggkRPyLqvI/MYzkbzOp0iTCrAAuBTC1P/VmmoGmEC008F9TYXOG6CKAP8B8y8tsX2eJriwAAAABJRU5ErkJggg=="
$imageBytes = [Convert]::FromBase64String($base64ImageString)
$ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
$ms.Write($imageBytes, 0, $imageBytes.Length);
$alkanelogo = [System.Drawing.Image]::FromStream($ms, $true)

$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width =  $alkanelogo.Size.Width;
$pictureBox.Height =  $alkanelogo.Size.Height; 
$pictureBox.Location = New-Object System.Drawing.Size(85,20) 
$pictureBox.Image = $alkanelogo;
#>
#----------------------------------------------------------------------------


$Labell = New-Object System.Windows.Controls.Label
$Labell.Content = "Right click and copy the settings you wish to activate `r Select OK."
$Labell.Margin = New-Object System.Windows.Thickness(10)

$listboxOptions = New-Object System.Windows.Controls.ListBox
$listboxOptions.Width = 200
$listboxOptions.Height = 200
$listboxOptions.Margin = New-Object System.Windows.Thickness(10)
$listboxOptions.ItemsSource = @("ChatGPT Open Options", "Reset Masked Selections","Suggestions", "Ideas", "Comments", "Thoughts") #3/9

$ContextMenu = New-Object System.Windows.Controls.ContextMenu

$MenuItem = New-Object System.Windows.Controls.MenuItem
$MenuItem.Header = "Copy"
$MenuItem.Add_Click({
$text = $listboxOptions.SelectedItem

if ($text -eq "Reset Masked Selections") 
{ 
    
    [System.Windows.Clipboard]::SetText($text)
    
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show('Masked Items Reset', 'Info', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

}

# Open ChatGPT Options from main menu...............................
if ($text -eq "ChatGPT Open Options") 
{ 
    
                        # Creates listbox to right click and execute command via watching the clipboard (This is a Chat Settings dialogbox and App config dialogbox = "Coming Soon")
                        Add-Type -AssemblyName PresentationFramework

                        $WindowChatt = New-Object System.Windows.Window
                        $WindowChatt.SizeGripStyle = "Hide"
                        $WindowChatt.MaximizeBox = $false


                        $WindowChatt.Title = "ChatGPT Settings Dialogbox" 
                        $WindowChatt.Width = 425
                        $WindowChatt.Height = 475
                        $WindowChatt.WindowStartupLocation = "CenterScreen"

                        $Labelll = New-Object System.Windows.Controls.Label
                        $Labelll.Content = "Right click and copy the setting you wish to activate `r Select OK. `r`r Note: These settings can be adjusted in TOOLS - Options `r Right Click and copy the ChatGPT Option"
                        $Labelll.Margin = New-Object System.Windows.Thickness(10)
                        

                        $listboxChatGPTt = New-Object System.Windows.Controls.ListBox
                        
                        $listboxChatGPTt.Width = 300
                        $listboxChatGPTt.Height = 200
                        
                        $listboxChatGPTt.Margin = New-Object System.Windows.Thickness(10)
                        $listboxChatGPTt.ItemsSource = @("ChatGPT Change GPT API", "ChatGPT Short Response", "ChatGPT Medium Response", "ChatGPT Complete Response", "ChatGPT Open Response Notepad", "ChatGPT Vocalize Response", "Open Windows Speech Settings", "ChatGPT Reset All Settings")
                        
                        $ContextMenuu = New-Object System.Windows.Controls.ContextMenu
                        $MenuItemm = New-Object System.Windows.Controls.MenuItem
                        $MenuItemm.Header = "Copy"
                        $MenuItemm.Add_Click({
                            $textt = $listboxChatGPTt.SelectedItem
                            [System.Windows.Clipboard]::SetText($textt)
                        })
                        $ContextMenuu.Items.Add($MenuItemm)
                        $listboxChatGPTt.ContextMenu = $ContextMenuu

                        $Buttonn = New-Object System.Windows.Controls.Button
                        $Buttonn.Content = "Close"
                        $Buttonn.Margin = New-Object System.Windows.Thickness(10)

                        $Buttonn.Add_Click(
                        { $WindowChatt.Close() })


                        $Labela = New-Object System.Windows.Controls.Label
                        $Labela.Content = "Developed by Duane Joseph (2023) / ChrisDee (GitHub 2016)"
                        $Labela.Margin = New-Object System.Windows.Thickness(10)
                        

                        $StackPanell = New-Object System.Windows.Controls.StackPanel
                        $StackPanell.Orientation = [System.Windows.Controls.Orientation]::Vertical
                        $StackPanell.Margin = New-Object System.Windows.Thickness(10)

                        $StackPanell.Children.Add($Labelll)
                        $StackPanell.Children.Add($listboxChatGPTt)
                        $StackPanell.Children.Add($Buttonn)
                        $StackPanell.Children.Add($Labela)
                        
                        $WindowChatt.Content = $StackPanell
                        $WindowChatt.ShowDialog() | Out-Null

 }


 

})


$ContextMenu.Items.Add($MenuItem)

$SubMenu = New-Object System.Windows.Controls.MenuItem
$SubMenu.Header = "Options"
$ContextMenu.Items.Add($SubMenu)

$Item1 = New-Object System.Windows.Controls.MenuItem
$Item1.Header = "Option 1"
$Item1.Add_Click({
Write-Host "Option 1 clicked"
})
$SubMenu.Items.Add($Item1)

$Item2 = New-Object System.Windows.Controls.MenuItem
$Item2.Header = "Option 2"
$Item2.Add_Click({
Write-Host "Option 2 clicked"
})
$SubMenu.Items.Add($Item2)

$listboxOptions.ContextMenu = $ContextMenu

$Button = New-Object System.Windows.Controls.Button
$Button.Content = "Close"
$Button.Margin = New-Object System.Windows.Thickness(10)
$Button.Add_Click({
$Window.Close()
})


$Labelc = New-Object System.Windows.Controls.Label
$Labelc.Content = "Developed by Duane Joseph (2023) / ChrisDee (GitHub 2016)"
$Labelc.Margin = New-Object System.Windows.Thickness(10)


$StackPanel = New-Object System.Windows.Controls.StackPanel
$StackPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical
$StackPanel.Margin = New-Object System.Windows.Thickness(10)
$StackPanel.Children.Add($Labell)
$StackPanel.Children.Add($listboxOptions)
$StackPanel.Children.Add($Button)
$StackPanel.Children.Add($Labelc)
$Window.Content = $StackPanel
$Window.ShowDialog() | Out-Null


})


    $Pause_Menu.Add_Click({ # 3/7
        if ($Pause_Menu.IsChecked -eq $False) {
            
            $Window.Title = $global:tempVar 
        } else {
            $global:tempVar = $Window.Title
            $Window.Title = "Pause - " + $global:tempVar 
        }
    })
    
    $Window.Add_Activated({
        $InputBox.Focus()
    })

    $Window.Add_SourceInitialized({
        #Create observable collection # 12/5
        $Script:ObservableCollection = New-Object System.Collections.ObjectModel.ObservableCollection[string]
        
        $Listbox.ItemsSource = $Script:ObservableCollection
        
        #Create Timer object
        $Script:timer = new-object System.Windows.Threading.DispatcherTimer 
        $timer.Interval = [TimeSpan]"0:0:.1"

        #Add event per tick
        $timer.Add_Tick({

            $text = $null
            
            $text =  Get-Clipboard
            If (($Script:Previous -ne $text -AND $Script:CopiedText -ne $text) -AND $text.length -gt 0) {
                
                if ($Global:Onload -eq $null) 
                {                
                    $hour = (Get-Date).Hour

                        if ($hour -ge 0 -and $hour -lt 12) {
                            $greeting = "Good Morning"
                            $Window.Title = $greeting
                        } elseif ($hour -ge 12 -and $hour -lt 18) {
                            $greeting = "Good Afternoon"
                            $Window.Title = $greeting
                        } else {
                            $greeting = "Have a good evening"
                            $Window.Title = $greeting
                        }

                        $Global:Onload = "true" #
                        #$Window.Topmost = $True
                        #$StayTop_Menu.activate($True)
                        #$StayTop_Menu.Add_Click()
                }

::InputBox
                
                if ($Pause_Menu.IsChecked -eq $False) {                    
                    if ($AddTime_Menu.IsChecked -eq $False) {

                        #
                        if ($text -eq "ChatGPT Change GPT API") 
                        { #3/10
                            
                            
                                    $global:chatGPTapiKey = $null # 3/10
                                    $global:ChangeGPTAPI = $null
                                
                                    # 2/21 - Added the API for testing purposes...............................................................................
                                    $defaultText = "Example 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"
                                    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
                                    $global:chatGPTapiKey = [Microsoft.VisualBasic.Interaction]::InputBox("Insert your CHATGPT API code. This is not saved and will be required after restarting everytime.", "Insert your CHATGPT API code", $defaultText)

                                            If ((($global:chatGPTapiKey -eq "Cancel") -or ($global:chatGPTapiKey -eq "") -or ($global:chatGPTapiKey -eq $null)))
                                            {
                                             
                                                # Testing ------------------ remove below
                                                [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
                                                #$noInputProvided = [Microsoft.VisualBasic.Interaction]::InputBox("Sorry sucker.........", "return initiated")
                                                [System.Windows.Forms.MessageBox]::Show('A value must exist - Please provide API key.', 'Info-21SSSSS576', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
                                                # Testing ------------------ remove above
                                                
                                                return
                                            }
                                        
                        } 


                        if ($text -eq "ChatGPT Short Response") 
                        { $global:ShortResponse = "ChatGPT Short Response" }
                            
                        if ($text -eq "ChatGPT Medium Response") 
                        { $global:MediumResponse = "ChatGPT Medium Response" }

                        if ($text -eq "ChatGPT Complete Response") 
                        { $global:CompleteResponse = "ChatGPT Complete Response" }

                        if ($text -eq "ChatGPT Vocalize Response") 
                        { $global:VocalizeResponse = "ChatGPT Vocalize Response" }

                        #
                        if ($text -eq "Open Windows Speech Settings") #  
                        { 
                            $global:OpenWindowsSpeech = "Open Windows Speech Settings"
                            Start-Process "ms-settings:speech" -WindowStyle Maximized

                        }
                                       
                        if ($text -eq "ChatGPT Open Response Notepad") #  
                        { 
                            $global:OpenResponseNotepad = "ChatGPT Open Response Notepad"                            
                        }

                        # Reset Masked Selections
                        if ($text -eq "Reset Masked Selections")
                        {                             
                            # Reset Masked Selections
                              $global:HideCopiedItems = $null                             

                        }



                           
                           if ($text -eq "ChatGPT Reset All Settings") 
                           { 
                            
                            #$global:ResetAllSettings = "ChatGPT Reset All Settings"  3/13
   
                                   $global:ChangeGPTAPI = ""
                                   $global:ShortResponse = ""
                                   $global:MediumResponse = ""
                                   $global:CompleteResponse = ""
                                   $global:VocalizeResponse = ""
                                   $global:OpenResponseNotepad = ""
                                   $global:ResetAllSettings = ""
                                   $global:chatGPTapiKey = ""
                                   $global:ChatGPTSelectedItem = $null
                                    [string] $global:chatGPTapiKey
                                    

                                   [Windows.Clipboard]::SetText("All Settings successfully reset.") # 3/10 All Settings successfully reset.
                                   [System.Windows.Forms.MessageBox]::Show('Cancel the ChatGPT form to start API key settings.', 'Info-2121zzzz6576', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)
                           }




                           
                                    if ($global:HideCopiedItems -match $text) 
                                    {     
                                        [void]$Script:ObservableCollection.Add("*************")                                                 

                                    }else
                                    {
                                        [void]$Script:ObservableCollection.Add($text)
                                    }

              
                                                
} else # Line 867 & 868 (If menu items selected = $Pause_Menu & $AddTime_Menu)
{
                            
                if ($global:HideCopiedItems -match $text) 
                                {
                                    [void]$Script:ObservableCollection.Add("*************  : " + (Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"))
                                                                        
                                }else
                                {
                                    [void]$Script:ObservableCollection.Add($text + " : " + (Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"))
                                }
                    }                       
                }

                $Script:Previous = $text
            }
             
        })
    
    
        $timer.Start()
        If (-NOT $timer.IsEnabled) {
            $Window.Close()
        }
    })

    $Window.Add_Closed({
        $Script:timer.Stop()
        $Script:ObservableCollection.Clear()
        $Runspacehash.PowerShell.Dispose()
    })

    $InputBox.Add_TextChanged({
        [System.Windows.Data.CollectionViewSource]::GetDefaultView($Listbox.ItemsSource).Filter = [Predicate[Object]]{             
            Try {
                $args[0] -match [regex]::Escape($InputBox.Text)
            } Catch {
                $True
            }
        }    
    })
    
    $listbox.Add_MouseRightButtonUp({
        If ($Script:ObservableCollection.Count -gt 0) {
            $Remove_Menu.IsEnabled = $True
            $Copy_Menu.IsEnabled = $True
        } Else {
            $Remove_Menu.IsEnabled = $False
            $Copy_Menu.IsEnabled = $False
        }
    })


    $Window.Add_KeyDown({ 
        $key = $_.Key  
        If ([System.Windows.Input.Keyboard]::IsKeyDown("RightCtrl") -OR [System.Windows.Input.Keyboard]::IsKeyDown("LeftCtrl")) {
            Switch ($Key) {
            "C" {
                Set-ClipBoard                                          
            }
            "R" {
                @($listbox.SelectedItems) | ForEach-Object {
                    [void]$Script:ObservableCollection.Remove($_)
                }            
            }
            "E" {
                $This.Close()
            }
            Default {$Null}
            }
        }
        If ([System.Windows.Input.Keyboard]::IsKeyDown("Enter")) {
            
            [void]$Script:ObservableCollection.RemoveAt($indexBox.Text)
            [void]$Script:ObservableCollection.Insert($indexBox.Text, $ItemEdit.Text)
            $ItemEdit.Visibility = "hidden"
        }
    })

    [void]$Window.ShowDialog()
    
  
}).BeginInvoke()


