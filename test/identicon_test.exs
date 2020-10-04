defmodule IdenticonTest do
    use ExUnit.Case

    test "can hash the user input" do
        %Identicon.Image{color: _, grid: _, hex: hex, pixel_map: _} = Identicon.hash_input "Mihai"
        assert hex == [80, 16, 7, 197, 237, 113, 240, 21, 51, 72, 162, 53, 46, 209, 84, 248]
    end

    test "can pick color" do
        %Identicon.Image{color: %{red: red, green: green, blue: blue}, grid: _, hex: _, pixel_map: _} = 
            "Mihai"
            |> Identicon.hash_input
            |> Identicon.pick_color
        assert red == 80
        assert green == 16
        assert blue == 7
    end

    test "can build the grid" do
        %Identicon.Image{color: _, grid: grid, hex: _, pixel_map: _} = 
            "Mihai"
            |> Identicon.hash_input
            |> Identicon.build_grid
        [ elem1, elem2, elem3 | _ ] = grid
        assert length(grid) == 25
        assert elem1 == {80, 0}
        assert elem2 == {16, 1}
        assert elem3 == {7, 2}
    end

    test "can filter squares with odd value" do
        %Identicon.Image{color: _, grid: grid, hex: _, pixel_map: _} = 
            "Mihai"
            |> Identicon.hash_input
            |> Identicon.build_grid
            |> Identicon.filter_odd_squares
        assert length(grid) == 13
        Enum.each grid, fn ({value, _}) -> assert rem(value, 2) == 0 end
    end

    test "can build the pixel map" do
        %Identicon.Image{color: _, grid: _, hex: _, pixel_map: pixel_map} = 
            "Mihai"
            |> Identicon.hash_input
            |> Identicon.build_grid
            |> Identicon.filter_odd_squares
            |> Identicon.build_pixel_map
        assert length(pixel_map) == 13
        Enum.each pixel_map, fn ({brx: brx, bry: bry, tlx: tlx, tly: tly}) -> 
            assert tlx
        end
    end
end