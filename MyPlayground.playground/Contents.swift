import Cocoa

let lang = "en"

typealias FreqTable = [String: Double]
var freqDict = FreqTable()
do {
  let data = try Data(contentsOf: URL(fileReferenceLiteralResourceName: "freq_\(lang).json"))
  let decoder = JSONDecoder()
  freqDict = try decoder.decode(FreqTable.self, from: data)
} catch {
  print ("Unable to open")
  abort()
}

/*
 * Words can be imported with
 * aspell -d en dump master | aspell -l en expand | sed -E -e 's/\w*\'//g;s/[[:blank:]]+/\n/g' | awk '{ if (length($0) == 5) print toupper($0) }' | uniq > words_en
 * aspell -d es dump master | aspell -l es expand | sed -E -e 's/[[:blank:]]+/\n/g;' | sed -n -e '/^.....$/p' | uniq | awk '{ print toupper($0) }' > MyPlayground.playground/Resources/words_es.txt
 */
var wordList = [String]()
if let path = Bundle.main.path(forResource: "words_\(lang)", ofType: "txt", inDirectory: nil),
   let contents = try? String(contentsOfFile: path) {
  let lines = contents.split(separator:"\n")
  wordList = lines.map {String($0)}
} else {
  print ("Unable to open")
  abort()
}
var yellowGuesses = [String]()
var yellowDiscards = [String]()
var grayLetters = [Character]()


let greenLettersPattern = "....."
//yellowGuesses = [".*A.*",".*T.*"]
//yellowDiscards = ["[^A]....","[^T]....","...[^A]."]
//grayLetters = Array("IREONS")

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
  return chars.reduce(0.0) { $0 + (freqDict[String($1)] ?? 0) }
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
print(wordList.count, wordList.sorted(by: { simpleAddFreq(word: $0) > simpleAddFreq(word: $1) }))

