# CalendarPuzzle

Solve CalendarPuzzle (ref: [https://twitter.com/ataboh/status/1390710476800073733](https://twitter.com/ataboh/status/1390710476800073733))

## Basic Usage

```bash
$ julia -E 'using Dates;today()'
Date("2021-05-09")

$ julia --project -e "using CalendarPuzzle;CalendarPuzzle.solve()"
  O  O  Y  U  5  U   
  O  O  Y  U  U  U   
  O  O  Y  Y  S  Z  Z
  L  9  Y  S  S  Z  V
  L  P  P  S  Z  Z  V
  L  P  P  S  V  V  V
  L  L  P            

```

## Solve All

```bash
$ mkdir -p answers
$ julia --project -e "using CalendarPuzzle;CalendarPuzzle.outputallanswers(\"$(cd answers && pwd)\")"
```

## Run Tests

```bash
$ julia --project -e "using Pkg;Pkg.test()"
    Updating registry at `~/.julia/registries/General`
  : «SNIPPED»
     Testing Running tests...
Test Summary: | Pass  Total
board         |    3      3
Test Summary: | Pass  Total
solve         |    1      1
     Testing CalendarPuzzle tests passed 
```
