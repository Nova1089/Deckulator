# functions
function GetDeckSize($numRanks, $numSuits)
{
    return $numRanks * $numSuits
}

function CalculateCombos($numCombos, $numRanks, $numSuits, $deckSize)
{
    $oddsList = New-Object System.Collections.Generic.List[object]
    for ([int]$i = 2; $i -lt $numCombos + 2; $i++)
    {
        # Calculate runs
        $possibleRuns = GetPossibleRuns -runSize $i -numRanks $numRanks -numSuits $numSuits
        $runOdds = GetRunOdds -runSize $i -possibleRuns $possibleRuns -deckSize $deckSize
        $oddsList.Add($runOdds)

        # Calculate sets
        $possibleSets = GetPossibleSets -setSize $i -numRanks $numRanks -numSuits $numSuits
        $setOdds = GetSetOdds -setSize $i -possibleSets $possibleSets -deckSize $deckSize
        $oddsList.Add($setOdds)

        # Calculate flush runs
        $possibleFlushRuns = GetPossibleFlushRuns -runSize $i -numRanks $numRanks -numSuits $numSuits
        $flushRunOdds = GetFlushRunOdds -runSize $i -possibleFlushRuns $possibleFlushRuns -deckSize $deckSize
        $oddsList.Add($flushRunOdds)

        # Calculate flushes
        $possibleFlushes = GetPossibleFlushes -flushSize $i -numRanks $numRanks -numSuits $numSuits
        $flushOdds = GetFlushOdds -flushSize $i -possibleFlushes $possibleFlushes -deckSize $deckSize
        $oddsList.Add($flushOdds)
    }
    # Calculate full houses
    $possibleFullHouses = GetPossibleFullHouses -numRanks $numRanks -numSuits $numSuits
    $fullHouseOdds = GetFullHouseOdds -possibleFullHouses $possibleFullHouses -deckSize $deckSize
    $oddsList.Add($fullHouseOdds)
    
    return $oddsList
}

function GetPossibleRuns($runSize, $numRanks, $numSuits)
{
    Write-Host "Run of $runSize`:"
    $waysToMakeRun = $numRanks - $runSize + 1
    Write-Host "With $numRanks ranks, there are $waysToMakeRun ways to make a run of $runSize." -ForegroundColor "DarkCyan"

    $suitCombos = [Math]::Pow($numSuits, $runSize)
    Write-Host "Each of the $runSize cards can be any of $numSuits suits, for a total of $suitCombos possibile combos." -ForegroundColor "DarkCyan"

    $possibleRuns = $waysToMakeRun * $suitCombos
    Write-Host "There are $waysToMakeRun * $suitCombos = $possibleRuns possible runs of $runSize." -ForegroundColor "DarkCyan"

    return $possibleRuns
}

function GetRunOdds($runSize, $possibleRuns, $deckSize)
{
    $possibleCombos = GetCombos -n $deckSize -r $runSize
    Write-Host "There are $possibleCombos possible combos if you take $runSize cards from the deck." -ForegroundColor "DarkCyan"
    [decimal]$runOdds = $possibleRuns / $possibleCombos
    $runOdds = [Math]::Round($runOdds, 12)
    Write-Host "Odds of a run of $runSize is: $possibleRuns / $possibleCombos = $runOdds" -ForegroundColor "DarkCyan"
    return [PSCustomObject]@{
        Name = "Run of $runSize"
        Odds = $runOdds
    }
}

# UInt64
function GetCombos([System.UInt64]$n, [System.UInt64]$r)
{
    if ($r -gt $n)
    {
        return 0
    }

    [System.UInt64]$k = 1;
    for ([System.UInt64]$d = 1; $d -le $r; ++$d)
    {
        $k *= $n--
        $k /= $d
    }
    return $k
}

function GetPossibleFlushRuns($runSize, $numRanks, $numSuits)
{
    Write-Host "Flush run of size $runSize`:"
    $waysToMakeRun = $numRanks - $runSize + 1
    Write-Host "With $numRanks ranks, there are $waysToMakeRun ways to make a run of $runSize." -ForegroundColor "DarkCyan"

    Write-Host "There are $numSuits suits, from which we choose 1, so $numSuits possibilities" -ForegroundColor "DarkCyan"
    $possibleFlushRuns = $waysToMakeRun * $numSuits
    Write-Host "There are $waysToMakeRun * $numSuits = $possibleFlushRuns possible flush runs of $runSize." -ForegroundColor "DarkCyan"

    return $possibleFlushRuns
}

function GetFlushRunOdds($runSize, $possibleFlushRuns, $deckSize)
{
    $possibleCombos = GetCombos -n $deckSize -r $runSize
    Write-Host "There are $possibleCombos possible combos if you take $runSize cards from the deck." -ForegroundColor "DarkCyan"
    [decimal]$flushRunOdds = $possibleFlushRuns / $possibleCombos
    $flushRunOdds = [Math]::Round($flushRunOdds, 12)
    Write-Host "Odds of a flush run of $runSize is: $possibleFlushRuns / $possibleCombos = $flushRunOdds" -ForegroundColor "DarkCyan"
        return [PSCustomObject]@{
        Name = "Flush run of $runSize"
        Odds = $flushRunOdds
    }
}

function GetPossibleSets($setSize, $numRanks, $numSuits)
{
    Write-Host "Set of $setSize`:"
    $possibleRanks = $numRanks
    Write-Host "Choose 1 rank from $numRanks, so $numRanks possibilities." -ForegroundColor "DarkCyan"

    $possibleSuitCombos = GetCombos -n $numSuits -r $setSize
    Write-Host "There are $numSuits suits, from which we choose $setSize, for $possibleSuitCombos possible suit combos." -ForegroundColor "DarkCyan"

    $possibleSets = $possibleRanks * $possibleSuitCombos
    Write-Host "There are $possibleRanks * $possibleSuitCombos = $possibleSets possible sets of $setSize." -ForegroundColor "DarkCyan"

    return $possibleSets
}

function GetSetOdds($setSize, $possibleSets, $deckSize)
{
    $possibleCombos = GetCombos -n $deckSize -r $setSize
    Write-Host "There are $possibleCombos possible combos if you take $setSize cards from the deck." -ForegroundColor "DarkCyan"
    [decimal]$setOdds = $possibleSets / $possibleCombos
    $setOdds = [Math]::Round($setOdds, 12)
    Write-Host "Odds of a set of $setSize is: $possibleSets / $possibleCombos = $setOdds" -ForegroundColor "DarkCyan"
    return [PSCustomObject]@{
        Name = "Set of $setSize"
        Odds = $setOdds
    }
}

function GetPossibleFlushes($flushSize, $numRanks, $numSuits)
{
    Write-Host "Flush of $flushSize`:"
    $possibleSuits = $numSuits
    Write-Host "Choose 1 suit from $numSuits, so $numSuits possibilities." -ForegroundColor "DarkCyan"

    $possibleRankCombos = GetCombos -n $numRanks -r $flushSize
    Write-Host "There are $numRanks ranks, from which we choose $flushSize, for $possibleRankCombos possible rank combos." -ForegroundColor "DarkCyan"

    $possibleFlushes = $possibleSuits * $possibleRankCombos
    Write-Host "There are $possibleSuits * $possibleRankCombos = $possibleFlushes possible flushes of $flushSize." -ForegroundColor "DarkCyan"

    return $possibleFlushes
}

function GetFlushOdds($flushSize, $possibleFlushes, $deckSize)
{
    $possibleCombos = GetCombos -n $deckSize -r $flushSize
    Write-Host "There are $possibleCombos possible combos if you take $flushSize cards from the deck." -ForegroundColor "DarkCyan"
    [decimal]$flushOdds = $possibleFlushes / $possibleCombos
    $flushOdds = [Math]::Round($flushOdds, 12)
    Write-Host "Odds of a flush of $flushSize, is: $possibleFlushes / $possibleCombos = $flushOdds" -ForegroundColor "DarkCyan"
        return [PSCustomObject]@{
        Name = "Flush of $flushSize"
        Odds = $flushOdds
    }
}

function GetPossibleFullHouses($numRanks, $numSuits)
{
    Write-Host "Full House`:"

    Write-Host "First calculate set of 3." -ForegroundColor "DarkCyan"
    $possibleRanks = $numRanks
    Write-Host "Choose 1 rank from $numRanks, so $numRanks possibilities." -ForegroundColor "DarkCyan"

    $possibleSuitCombos = GetCombos -n $numSuits -r 3
    Write-Host "There are $numSuits suits, from which we choose 3, for $possibleSuitCombos possible suit combos." -ForegroundColor "DarkCyan"

    $possibleSetsOf3 = $possibleRanks * $possibleSuitCombos
    Write-Host "There are $possibleRanks * $possibleSuitCombos = $possibleSetsOf3 possible sets of 3." -ForegroundColor "DarkCyan"


    Write-Host "Next calculate set of 2 from the remaining cards." -ForegroundColor "DarkCyan"
    $possibleRanks = $numRanks - 1
    Write-Host "Choose 1 rank from $($numRanks - 1), so $($numRanks - 1) possibilities." -ForegroundColor "DarkCyan"

    $possibleSuitCombos = GetCombos -n $numSuits -r 2
    Write-Host "There are $numSuits suits, from which we choose 2, for $possibleSuitCombos possible suit combos." -ForegroundColor "DarkCyan"

    $possibleSetsOf2 = $possibleRanks * $possibleSuitCombos
    Write-Host "There are $possibleRanks * $possibleSuitCombos = $possibleSetsOf2 possible sets of 2." -ForegroundColor "DarkCyan"

    $possibleFullHouses = $possibleSetsOf3 * $possibleSetsOf2
    Write-Host "Therefore there are $possibleSetsOf3 * $possibleSetsOf2 = $possibleFullHouses possible full houses." -ForegroundColor "DarkCyan"

    return $possibleFullHouses
}

function GetFullHouseOdds($possibleFullHouses, $deckSize)
{
    $possibleCombos = GetCombos -n $deckSize -r 5
    Write-Host "There are $possibleCombos possible combos if you take 5 cards from the deck." -ForegroundColor "DarkCyan"
    [decimal]$fullHouseOdds = $possibleFullHouses / $possibleCombos
    $fullHouseOdds = [Math]::Round($fullHouseOdds, 12)
    Write-Host "Odds of a full house is: $possibleFullHouses / $possibleCombos = $fullHouseOdds" -ForegroundColor "DarkCyan"
    return [PSCustomObject]@{
        Name = "Full house"
        Odds = $fullHouseOdds
    }
}

function ShowSortedOddsList($oddsList)
{
    Write-Host "Odds list:" -ForegroundColor "Green"
    $oddsList | Sort-Object "Odds" | Out-Host 
}

# main
[int]$numRanks = Read-Host "Enter the number of ranks"
[int]$numSuits = Read-Host "Enter the number of suits"
[int]$numCombos = Read-Host "Enter the number of combos to calculate"
[int]$deckSize = GetDeckSize -numRanks $numRanks -numSuits $numSuits
Write-Host "The total deck size is: $deckSize"
$oddsList = CalculateCombos -numCombos $numCombos -numRanks $numRanks -numSuits $numSuits -deckSize $deckSize
ShowSortedOddsList $oddsList

# UInt128 - User PowerShell 7
# function GetCombos([System.UInt128]$n, [System.UInt128]$r)
# {
#     if ($r -gt $n)
#     {
#         return 0
#     }
# 
#     [System.UInt128]$k = 1;
#     for ([System.UInt128]$d = 1; $d -le $r; ++$d)
#     {
#         $k *= $n--
#         $k /= $d
#     }
#     return $k
# }

# Hybrid - User PowerShell 7
# function GetCombos([System.UInt128]$n, [System.UInt128]$r)
# {
#     if ($r -gt $n)
#     {
#         return 0
#     }
# 
#     [System.UInt64]$k = 1;
#     for ([System.UInt64]$d = 1; $d -le $r; ++$d)
#     {
#         $k *= $n--
#         $k /= $d
#     }
#     return $k
# }



# Winner, whoever gets closest to (or exactly) 21 without going over.

# Problems to solve

# Given a deck of 108 cards (8 copies of 1-13 and 4 wizards), and a hand size of 13, 
# what is the probability of being dealt a set of 2, set of 3, run of 3, set of 4, run of 4, etc.
# Also, how many of each of these combo types are possible in the deck?

# Terms:
# Population = Deck
# Item = Card
# Success = A card you want to be dealt
# Sample = The hand that you are dealt
# 


# N = number of items in the population
# k = number of items in the population that are classified as successes
# m = number of items in the sample
# x = number of items in the sample that are classified as successes
# A = The event you want to occur.
# P(A) = The probability that the event A occurs. A will be expressed as a number between 0 and 1.
# The sum of probabilities for all possible outcomes is equal to 1. For exampple, if an experiment can have three possible outcomes (A, B, and C),
# then 

# Problem 1:
# Calculate the odds of drawing one of 3 cards out of a sample of 7.
# a = k / N
# So if you were happy to draw one of 3 cards out of a deck of 7. Your odds are 3 out of 7 = 3/7 = 43%.