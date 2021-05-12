module CalendarPuzzle

# ref: https://twitter.com/ataboh/status/1390710476800073733

using Dates

const BOARD_H = 10
const BOARD_W = 10
const PADDING_B = 3
const PADDING_R = 3

function makeboard(
    board_size=(BOARD_H, BOARD_W),
    padding_bottom=PADDING_B,
    padding_right=PADDING_R
)
    board = fill(-1, board_size)
    field_h, field_w = board_size .- (padding_bottom, padding_right)
    board[1:field_h, 1:field_w] .= 0
    for (x, y) in fldmod1.([28, 35, 42, 43, 44, 49], 7)
        board[y, x] = -1
    end
    board
end

function makeboard(
    dt::Date,
    board_size=(BOARD_H, BOARD_W),
    padding_bottom=PADDING_B,
    padding_right=PADDING_R
)
    m, d = Dates.monthday(dt)
    board = makeboard(board_size, padding_bottom, padding_right)
    my, mx = fldmod1(m, 6)
    dy, dx = fldmod1(d + 14, 7)
    board[my, mx] = -1
    board[dy, dx] = -1
    board
end

const PIECES = [:O, :L, :P, :S, :U, :V, :Y, :Z]
const PIECE_DATA = let dy=1, dx=BOARD_H
    Dict(
        :O => [
            cumsum([0, dy, dy, dx-2dy, dy, dy]),
            cumsum([0, dx, dx, dy-2dx, dx, dx])
        ],
        :L => [
            cumsum([0, dy, dy, dy, dx]),
            cumsum([0, dy, dy, dy, dx-3dy]),
            cumsum([0, dx, dy, dy, dy]),
            cumsum([0, dx-3dy, dy, dy, dy]),
            cumsum([0, dx, dx, dx, dy]),
            cumsum([0, dx, dx, dx, dy-3dx]),
            cumsum([0, dy, dx, dx, dx]),
            cumsum([0, dx, dx, dx, -dy]),
        ],
        :P => [
            cumsum([0, dy, dy, dx-2dy, dy]),
            cumsum([0, dy, dy, dx-dy, dy]),
            cumsum([0, dy, dx-dy, dy, dy]),
            cumsum([0, dy, dx-2dy, dy, dy]),
            cumsum([0, dx, dx, dy-2dx, dx]),
            cumsum([0, dx, dx, dy-dx, dx]),
            cumsum([0, dx, dy-dx, dx, dx]),
            cumsum([0, dx, dx, -dy-dx, dx]),
        ],
        :S => [
            cumsum([0, dy, dx, dy, dy]),
            cumsum([0, dy, dy, dx, dy]),
            cumsum([0, dy, dx-3dy, dy, dy]),
            cumsum([0, dy, dy, dx-3dy, dy]),
            cumsum([0, dx, dy, dx, dx]),
            cumsum([0, dx, dx, dy, dx]),
            cumsum([0, dx, -dy, dx, dx]),
            cumsum([0, dx, dx, -dy, dx]),
        ],
        :U => [
            cumsum([0, dy, dy, dx-2dy, 2dy]),
            cumsum([0, 2dy, dx-2dy, dy, dy]),
            cumsum([0, dx, dx, dy-2dx, 2dx]),
            cumsum([0, 2dx, dy-2dx, dx, dx]),
        ],
        :V => [
            cumsum([0, dy, dy, dx, dx]),
            cumsum([0, dy, dy, dx-2dy, dx]),
            cumsum([0, dx, dx, dy, dy]),
            cumsum([0, dx, dx, -dy, -dy]),
        ],
        :Y => [
            cumsum([0, dy, dy, dy, dx-2dy]),
            cumsum([0, dy, dy, dy, dx-dy]),
            cumsum([0, dx-dy, dy, dy, dy]),
            cumsum([0, dx-2dy, dy, dy, dy]),
            cumsum([0, dx, dx, dx, dy-2dx]),
            cumsum([0, dx, dx, dx, dy-dx]),
            cumsum([0, dx, dx, dx, -dy-2dx]),
            cumsum([0, dx, dx, dx, -dy-dx]),
        ],
        :Z => [
            cumsum([0, dy, dx, dx, dy]),
            cumsum([0, dy, dx-dy, dx, -dy]),
            cumsum([0, dx, dy, dy, dx]),
            cumsum([0, dx, -dy, -dy, dx]),
        ]
    )
end

function printboard(io::IO, board::AbstractMatrix, padding_bottom=PADDING_B, padding_right=PADDING_R)
    h, w = size(board) .- (padding_bottom, padding_right)
    function calcrow(y, row)
        w = length(row)
        strrow = if y < 3
            _r = lpad.((1:w) .+ (y - 1) .* 6, 3)
            _r[7:w] .= "   "
            _r
        else
            _ds = (1:w) .+ (y - 3) .* 7
            _r = lpad.(_ds, 3)
            _r[8:w] .= "   "
            _r[_ds .> 31] .= "   "
            _r
        end
        strrow[row .> 0] .= lpad.(PIECES[row[row .> 0]], 3)
        strrow
    end
    for y = 1:h
        println(io, calcrow(y, board[y, 1:w])...)
    end
end

availablepiece(board, pos, piece) = all(board[piece .+ pos] .== 0)

function putpiece(board, pos, piece, pidx)
    newboard = copy(board)
    newboard[piece .+ pos] .= pidx
    newboard
end

function find_nextpos(board, pos)
    findnext(eachindex(IndexLinear(), board), pos) do idx
        board[idx] == 0
    end
end

function solve_rec(fn, board, pos, pflags)
    if !any(pflags)
        # solved
        fn(board)
        return
    end
    pids = findall(pflags)
    for pid in pids
        for piece in PIECE_DATA[PIECES[pid]]
            if availablepiece(board, pos, piece)
                # recursive call
                newboard = putpiece(board, pos, piece, pid)
                newflags = copy(pflags)
                newflags[pid] = false
                nextpos = find_nextpos(newboard, pos)
                solve_rec(fn, newboard, nextpos, newflags)
            end
        end
    end
end

args2date() = Dates.today()
args2date(dt::Date) = dt
args2date(m::Int, d::Int) = Date(2020, m, d)  # Must be leap year! 

function printresultfn(io::IO)
    function (board)
        printboard(io, board)
        println(io)
    end
end

function solve_all(fn, board)
    solve_rec(fn, board, find_nextpos(board, 1), trues(length(PIECES)))
end

function solve_one(fn, board)
    chnl = Channel{Matrix{Int}}(1) do chnl
        first_pos = find_nextpos(board, 1)
        solve_rec(board, first_pos, trues(length(PIECES))) do result
            put!(chnl, result)
        end
    end
    # 
    try
    for result in chnl
            fn(result)
            return
        end
        println(stderr, "No Answers!")
    finally
        close(chnl)
    end
end

function hasanswer(args...)
    dt = args2date(args...)
    board = makeboard(dt)
    chnl = Channel{Matrix{Int}}(1) do chnl
        first_pos = find_nextpos(board, 1)
        solve_rec(board, first_pos, trues(length(PIECES))) do result
            put!(chnl, result)
        end
    end
    # 1つでも解が見つかれば終了
    try
    return !isnothing(iterate(chnl))
    finally
        close(chnl)
    end
end

function countanswers(args...)
    dt = args2date(args...)
    board = makeboard(dt)
    cnt = Ref(0)
    first_pos = find_nextpos(board, 1)
    solve_rec(board, first_pos, trues(length(PIECES))) do _
        cnt[] += 1
    end
    return cnt[]
end

function solve(args...; kwds...)
    dt = args2date(args...)
    fn = printresultfn(get(kwds, :io, stdout))
    board = makeboard(dt)
    if get(kwds, :all, false)
        solve_all(fn, board)
    else
        solve_one(fn, board)
    end
end

# solve()

function countallanswers()
    for dt in Date(2020,1,1):Day(1):Date(2020,12,31)
        print("#answer of $(dt): ")
        println(countanswers(dt), ".")
    end
end

function outputallanswers(destdir=pwd())
    for dt in Date(2020,1,1):Day(1):Date(2020,12,31)
        print("solving $(dt)...")
        destpath = joinpath(destdir, Dates.format(dt, dateformat"yyyymmdd.txt"))
        open(destpath, "w") do f
            solve(dt; io=f, all=true)
        end
        println("Done.")
    end
end

end # module
