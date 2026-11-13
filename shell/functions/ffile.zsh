# Find files whose name contains the argument (case-insensitive)
ffile() { find . -type f -iname "*$1*";}
