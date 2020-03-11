import           Language.SMT2.Parser
import           Test.HUnit

-- * Parsing tests
-- Test cases are from
--   1. the original [spec](http://smtlib.cs.uiowa.edu/papers/smt-lib-reference-v2.6-r2017-07-18.pdf).
--   2. HORN clause samples from [SV-COMP](https://github.com/sosy-lab/sv-benchmarks) & [benchmarks](https://github.com/hopv/benchmarks/).
--   3. Examples of horn-like clauses with disjuction on heads.

-- | parse and test a string, expecting @a@
pe :: (Eq a, Show a) => GenStrParser () a -> String -> a -> Test
pe p s expected = TestCase $ case parseStringEof p s of
                    Right actual -> expected @=? actual
                    Left _ -> assertFailure $ "should succeed for " <> s

-- | parse and test a string, expecting a parser error (@Left _@)
pf :: GenStrParser () a -> String -> Test
pf p s = TestCase $ case parseStringEof p s of
           Left _  -> pure ()
           Right _ -> assertFailure $ "should fail for " <> s

-- | Sec 3.1
lexiconTest = TestList [ pN "0" ("0" :: Numeral)
                       , pN "42" ("42" :: Numeral)
                       , pf numeral "02"   -- ^ should not start with 0
                       , pf numeral "221b" -- ^ should not contain letters
                       , pD "0.0" ("0.0" :: Decimal)
                       , pD "0.00" ("0.00" :: Decimal)
                       , pD "0.1" ("0.1" :: Decimal)
                       , pD "13.37" ("13.37" :: Decimal)
                       , pD "1.010" ("1.010" :: Decimal)
                       , pf decimal ".5"
                       , pH "#x0" ("0" :: Hexadecimal)
                       , pH "#xa04" ("a04" :: Hexadecimal)   -- ^ alphabet
                       , pH "#xA04" ("a04" :: Hexadecimal)   -- ^ alphabet, to lower case
                       , pH "#x01Ab" ("01ab" :: Hexadecimal) -- ^ mixture
                       , pH "#x61ff" ("61ff" :: Hexadecimal)
                       , pH "#xdeadbeef" ("deadbeef" :: Hexadecimal)
                       , pf hexadecimal "#x#x"    -- ^ signs
                       , pf hexadecimal "#xA1G01" -- ^ letter is not hex degit
                       , pB "#b0" ("0" :: Binary)
                       , pB "#b1" ("1" :: Binary)
                       , pB "#b001" ("001" :: Binary)
                       , pB "#b101011" ("101011" :: Binary)
                       , pf binary "#b02"
                       , pL "\"\"" ("" :: StringLiteral)
                       , pL "\"this is a string literal\"" ("this is a string literal" :: StringLiteral)
                       , pL "\"one\\n two\"" ("one\\n two" :: StringLiteral) -- ^ non-escape
                       , pL "\"She said: \\\"Hello!\\\"\"" ("She said: \"Hello!\"" :: StringLiteral)
                       , pL "\"Here is a backslash: \\\\\"" ("Here is a backslash: \\" :: StringLiteral)
                       , pR "par" ("par" :: ReservedWord)
                       , pR "NUMERAL" ("NUMERAL" :: ReservedWord)
                       , pR "_" ("_" :: ReservedWord)
                       , pR "!" ("!" :: ReservedWord)
                       , pR "as" ("as" :: ReservedWord)
                       , pR "set-logic" ("set-logic" :: ReservedWord)
                       , pf reservedWord "asleep" -- ^ prefix
                       , pf symbol "par" -- ^ symbol should not be a reserved word
                       , pf symbol "NUMERAL"
                       , pf symbol "_"
                       , pf symbol "!"
                       , pf symbol "as"
                       , pS "asleep" ("asleep" :: Symbol) -- ^ prefixed by a reserved word
                       , pS "+" ("+" :: Symbol)
                       , pS "<=" ("<=" :: Symbol)
                       , pS "x" ("x" :: Symbol)
                       , pS "**" ("**" :: Symbol)
                       , pS "$" ("$" :: Symbol)
                       , pS "<sas" ("<sas" :: Symbol)
                       , pS "<adf>" ("<adf>" :: Symbol)
                       , pS "abc77" ("abc77" :: Symbol)
                       , pS "*$s&6" ("*$s&6" :: Symbol)
                       , pS ".kkk" (".kkk" :: Symbol)
                       , pS ".8" (".8" :: Symbol)
                       , pS "+34" ("+34" :: Symbol)
                       , pS "-32" ("-32" :: Symbol)
                       , pS "|this is a single quoted symbol|" ("this is a single quoted symbol" :: Symbol)
                       , pS "||" ("" :: Symbol)
                       , pS "|af kljˆ∗(0asfsfe2(&∗)&(#ˆ$>>>?”’]]984|" ("af kljˆ∗(0asfsfe2(&∗)&(#ˆ$>>>?”’]]984" :: Symbol)
                       , pS "|abc|" ("abc" :: Symbol) -- ^ quoted simple symbol is the same
                       , pS "abc" ("abc" :: Symbol)
                       , pK ":date" ("date" :: Keyword)
                       , pK ":a2" ("a2" :: Keyword)
                       , pK ":foo-bar" ("foo-bar" :: Keyword)
                       , pK ":<=" ("<=" :: Keyword)
                       , pK ":56" ("56" :: Keyword)
                       , pK ":->" ("->" :: Keyword)
                       , pK ":~!@$%^&*_-+=<>.?/" ("~!@$%^&*_-+=<>.?/" :: Keyword)
                       ]
  where
    pN = pe numeral
    pD = pe decimal
    pH = pe hexadecimal
    pB = pe binary
    pL = pe stringLiteral
    pR = pe reservedWord
    pS = pe symbol
    pK = pe keyword


specTest = TestList [ lexiconTest ]

hornTest = TestCase $ pure ()

disjuctionTest = TestCase $ pure ()

tests = TestList [ TestLabel "spec" specTest
                 , TestLabel "horn" hornTest
                 , TestLabel "disjuction" disjuctionTest
                 ]

main :: IO ()
main = do
  counts <- runTestTT tests
  print counts
