# Open a man page as a PDF in Preview. Preview no longer opens the PostScript
# that `man -t` produces, so mandoc renders the PDF directly.
manpdf() {
  local page
  page=$(man -w "$1") || return
  mandoc -T pdf "$page" | open -f -a Preview
}
