Function OpenWordDoc ($filename) {
    $word = New-Object -ComObject word.application
    $def = [System.Type]::Missing
    $word.documents.open($filename, $def, $def, $def, $def, $def, $def, $def, $def, $def, $def, $true)
    #$word.visible = $true
}

$word.activewindow.selection.find()
