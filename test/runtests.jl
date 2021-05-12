module CalendarPuzzleTests

using CalendarPuzzle
using Dates
using Test

@testset "board" begin
    board_7x7 = CalendarPuzzle.makeboard((7, 7), 0, 0)
    @test board_7x7 == [
        0  0  0  0  0  0 -1
        0  0  0  0  0  0 -1
        0  0  0  0  0  0  0
        0  0  0  0  0  0  0
        0  0  0  0  0  0  0
        0  0  0  0  0  0  0
        0  0  0 -1 -1 -1 -1
    ]
    board = CalendarPuzzle.makeboard()
    @test board == [
         0  0  0  0  0  0 -1 -1
         0  0  0  0  0  0 -1 -1
         0  0  0  0  0  0  0 -1
         0  0  0  0  0  0  0 -1
         0  0  0  0  0  0  0 -1
         0  0  0  0  0  0  0 -1
         0  0  0 -1 -1 -1 -1 -1
        -1 -1 -1 -1 -1 -1 -1 -1
    ]

    board_May09 = CalendarPuzzle.makeboard(Date(2021, 5, 9))
    @test board_May09 == [
         0  0  0  0 -1  0 -1 -1
         0  0  0  0  0  0 -1 -1
         0  0  0  0  0  0  0 -1
         0 -1  0  0  0  0  0 -1
         0  0  0  0  0  0  0 -1
         0  0  0  0  0  0  0 -1
         0  0  0 -1 -1 -1 -1 -1
        -1 -1 -1 -1 -1 -1 -1 -1
    ]
end

@testset "solve" begin
    @test all(CalendarPuzzle.hasanswer(dt) for dt in Date(2020,1,1):Day(1):Date(2020,12,31))
end

end