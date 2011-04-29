for f in *.txt; 
    do iconv -f mac -t utf-8 "$f" >"$f.utf8"; 
done