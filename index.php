<?php
if ($handle = opendir('.')) {

    while (false !== ($entry = readdir($handle))) {

        if ($entry != "." && $entry != "..") {
            echo sprintf("<a href='/build/%s'>%s</a> <br>\n", $entry, $entry);
        }
    }

    closedir($handle);
}?>
