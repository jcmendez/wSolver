import Cocoa

let freqDict : [Character: Double] = [
  "A": 0.0849748862031078,
  "B": 0.0207188824360383,
  "C": 0.0453814157902998,
  "D": 0.0338447653429603,
  "E": 0.11159943493957,
  "F": 0.0181290221315335,
  "G": 0.0247017736619055,
  "H": 0.0300384555014911,
  "I": 0.0754394914456129,
  "J": 0.0019620153822006,
  "K": 0.0110069062941453,
  "L": 0.0548971903939727,
  "M": 0.0301365562706012,
  "N": 0.0665515617642442,
  "O": 0.0716331816041438,
  "P": 0.0316669282687176,
  "Q": 0.0019620153822006,
  "R": 0.075812274368231,
  "S": 0.0573497096217234,
  "T": 0.0695142049913671,
  "U": 0.036316904724533,
  "V": 0.0100651389106891,
  "W": 0.0128904410610579,
  "X": 0.00290378276565688,
  "Y": 0.0177758593627374,
  "Z": 0.00272720138125883
]

/*
 * Words can be imported with
 * aspell -d en dump master | aspell -l en expand | sed -E -e 's/\w*\'//g;s/[[:blank:]]+/\n/g' | awk '{ if (length($0) == 5) print toupper($0) }' | uniq > words_en
 * aspell -d es dump master | aspell -l es expand | sed -E -e 's/[[:blank:]]+/\n/g' | iconv -f utf8 -t ascii | awk '{ if (length($0) == 5) print toupper($0) }' | uniq > words_es
 */
var wordList = [String]()
if let path = Bundle.main.path(forResource: "words_en", ofType: "txt", inDirectory: nil),
   let contents = try? String(contentsOfFile: path) {
  let lines = contents.split(separator:"\n")
  wordList = lines.map {String($0)}
} else {
  print ("Unable to open")
}
var yellowGuesses = [String]()
var yellowDiscards = [String]()
var grayLetters = [Character]()


let greenLettersPattern = "FRE.."
yellowGuesses = [".*E.*"]
yellowDiscards = ["....[^E]"]
grayLetters = ["I","A","T","O","N"]

func wordContainsLetter(word: String, letter: Character) -> Bool {
  return word.contains(letter)
}

// This function helps eliminate any words that have gray letters
func wordContainsGrayLetters(word: String) -> Bool {
  let kk = grayLetters.map { wordContainsLetter(word: word, letter: $0)}
  return kk.contains(true)
}

func simpleAddFreq(word: String) -> Double {
  let chars = Set(Array(word))
  return chars.reduce(0.0) { $0 + freqDict[$1]! }
}

// Solution approach:
// Put 'IRATE', 'ROATE' or 'OUIJA' as first guess
// Until solved:
// * Use results to add to arrays:
//   - any green gets added to greenLettersPattern in the correct position
//   - all grays get added to grayLetters
//   - a new yellow gets added to yellowGuesses in the form ".*A.*"
//   - a new yellow gets added to yellowDiscards in the form "....[^A]","[^A]....","...[^E]." (position)
// * Get an array with all 5 letter words
// * Remove all the words that contain gray letters
// * Filter to include only green letter pattern
// * Further reduce the list by using the yellow letters, meaning
//   - must include the yellow letter in some other place than current, but
//     can't have the yellow letter in its current place

wordList = wordList.filter { !wordContainsGrayLetters(word: $0) }
wordList = wordList.filter { $0.range(of: greenLettersPattern, options: .regularExpression) != nil }
for discard in yellowDiscards {
  wordList = wordList.filter { $0.range(of: discard, options: .regularExpression) != nil }
}
for guess in yellowGuesses {
  wordList = wordList.filter { $0.range(of: guess, options: .regularExpression) != nil }
}
print(wordList.sorted(by: { simpleAddFreq(word: $0) > simpleAddFreq(word: $1) }))

