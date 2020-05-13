defmodule Identicon do
  require Integer

  def main(string) do
    string
    |>string_to_hash
    |>set_color
    |>set_grid
    |>filter_odd
    |>set_pixel_map
    |>draw_image
    |>save(string)
  end

  def save(image, string) do
    File.write("#{string}.png", image)
  end

  def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def set_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn {_code, index} ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn {k,_v} -> Integer.is_even(k) end
    
    %Identicon.Image{image | grid: grid}
  end

  def set_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |>Enum.chunk(3)
    |>Enum.map( fn [a, b, c] -> [a, b, c, b, a] end )
    # OU Enum. map(&mirror_row/1)
    # mirror_row(row) -> [first, second | _tail] = row
    # row ++ [second, first]
    |>List.flatten
    |>Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def set_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    
    %Identicon.Image{image | color: {r, g, b}}
  end

  def string_to_hash(string) do
    hex = :crypto.hash(:md5, string)
    |>:binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
