import strutils

proc getSeq(key: TaintedString): string =
  let file = "knucleotide-input.txt".open()
  var line: TaintedString
  while file.readLine(line):
    if line.startsWith(key):
      break
  
  while file.readLine(line):
    result.add(line)


proc calc() =
  let s = getSeq(">THREE")
  echo $s

when isMainModule:
  calc()

