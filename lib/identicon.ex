defmodule Identicon do

    defguard has_three_elem(value) when is_list(value) and length(value) == 3

    def main(input) when is_binary(input) do
        input
        |> String.downcase
        |> hash_input
        |> pick_color
        |> build_grid
        |> filter_odd_squares
        |> build_pixel_map
        |> draw_image
        |> save_image(input)
    end

    def hash_input(input) when is_binary(input) do
        :crypto.hash(:md5, input) 
        |> :binary.bin_to_list
        |> new_image
    end

    def pick_color(%Identicon.Image{hex: hex}) when is_list(hex) do
        case length(hex) > 3 do
            true -> 
                [ r, g, b | _ ] = hex
                %Identicon.Image{hex: hex, color: %{red: r, green: g, blue: b}}
            false -> "List should have more then 3 elements"
        end
    end

    def build_grid(%Identicon.Image{hex: hex} = image) do
        hex
        |> Enum.chunk_every(3, 3, :discard)
        |> Enum.map(&mirror_row/1)
        |> List.flatten
        |> Enum.with_index
        |> add_grid_to_img(image)
    end

    def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
        filtered_grid = Enum.filter(grid, fn {code, _} -> is_even?(code) end)
        %Identicon.Image{image | grid: filtered_grid}
    end

    def build_pixel_map(%Identicon.Image{grid: grid} = image) do
        pixel_map = for {_, index} <- grid do
            tlx = rem(index, 5) * 50
            tly = div(index, 5) * 50
            %{tlx: tlx, tly: tly, brx: tlx + 50, bry: tly + 50}
        end
        %Identicon.Image{image | pixel_map: pixel_map}
    end

    def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
        image = :egd.create(250, 250)
        fill = :egd.color({color.red, color.green, color.blue})

        Enum.each pixel_map, fn(%{brx: brx, bry: bry, tlx: tlx, tly: tly}) ->
            :egd.filledRectangle(image, {tlx, tly}, {brx, bry}, fill)
        end

        :egd.render(image)
    end

    def save_image(binary, file_name) when is_binary(binary) and is_binary(file_name) do
        file_name
        |> String.downcase
        |> create_file_name
        |> File.write(binary)
    end

    def new_image([first | _] = hex) when is_list(hex) and is_integer(first) do
        %Identicon.Image{hex: hex}
    end

    def mirror_row(row) when has_three_elem(row) do
        [first, second | _ ] = row
        row ++ [second, first]
    end

    def is_even?(value) when is_integer(value) do
        rem(value, 2) == 0
    end

    def add_grid_to_img(grid, %Identicon.Image{} = image) when is_list(grid) do
        %Identicon.Image{image | grid: grid}
    end

    def create_file_name(file_name) when is_binary(file_name) do
        "identicons/" <> file_name <> "_identicon.jpg"
    end

end
