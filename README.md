# smt2-parser

A Haskell parser for [SMT-LIB](http://smtlib.cs.uiowa.edu/) version 2.6 [^1]. [The language reference](http://smtlib.cs.uiowa.edu/language.shtml) is available in [pdf](http://smtlib.cs.uiowa.edu/papers/smt-lib-reference-v2.6-r2017-07-18.pdf).

## Usage

Run a parser with an input string:

```hs
-- parseStringEof :: Parser a -> T.Text -> Either ParseError a

parseStringEof numeral "0" === Right ("0" :: Numeral)
parseStringEof identifier "(_ BitVec 32)" === Right (IdIndexed ("BitVec" :: Symbol) (fromList [IxNumeral "32"]))
```

Run a parser from a file string, possibly leading and trailing by spaces and having comments

```hs
-- parseFileMsg :: Parser a -> T.Text -> Either T.Text a
>>> parseFileMsg script (T.pack "(set-logic HORN)\n\n(declare-fun |sum$unknown:2|\n  ( Int Int ) Bool\n)\n(assert\n  (forall ( (|$V-reftype:10| Int) (|$alpha-1:n| Int) (|$knormal:1| Int) (|$knormal:2| Int) (|$knormal:3| Int) )\n    (=>\n      ( and (= |$knormal:2| (- |$alpha-1:n| 1)) (= (not (= 0 |$knormal:1|)) (<= |$alpha-1:n| 0)) (= |$V-reftype:10| (+ |$alpha-1:n| |$knormal:3|)) (not (not (= 0 |$knormal:1|))) (|sum$unknown:2| |$knormal:3| |$knormal:2|) true )\n      (|sum$unknown:2| |$V-reftype:10| |$alpha-1:n|)\n    )\n  )\n)(check-sat)")

Right [ SetLogic "HORN"
      , DeclareFun "sum$unknown:2" [SortSymbol (IdSymbol "Int"),...] (SortSymbol (IdSymbol "Bool"))
      , Assert (TermForall ...)
      , CheckSat
      ]
```

## Known Issue

`removeComment` may cause performance issue. Use `parseCommentFreeFileMsg` on a preprocessed comment-free file instead.

[^1]: Barrett, Clarke, Pascal Fontaine and Cesare Tinelli. The SMT-LIB Standard: Version 2.6. Technical Report BarFT-RR-17, Department of Computer Science, The University of Iowa, 2017. Available at www.SMT-LIB.org

