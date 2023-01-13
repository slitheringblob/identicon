defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  generate a identicon for 300x300px from an input string.
  Based on strings so the same string generates the same identicon
  """
  def main(input) do
    
    input 
    |> hash_input
    |> colorpicker
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)

  end


  @doc """
    We want to md5 hash the string then binary encode it to get a
    list of values(co-ordinates)
    hash = :cypto.hash(:md5,input)
    :binary.bin_to_list(hash)

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5,input) 
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end


  @doc """
  set the color to fill the grid with  
  iex(5)> Identicon.main("banana")
    [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
    [114, 179,2] = rgb(114,179,2) # this will be our colour
    We want to set colours for even numbers in the list
  """
  def colorpicker(image) do
    #image represents the image struct
    #[r,g,b | _tail] = hexlist
    # hex: hexlist
    # this has been comprehended into a squishy boi
    %Identicon.Image{hex: [r,g,b | _tail]} = image
    #making a new image cuz we dont modify existing data and appending the rgb as a color property value
    %Identicon.Image{image | color: {r,g,b}}
  end


  @doc """
    this set of 2 functions will make our 5x5 grid from 16 hex values in the image
    `build_grid` will make the chunks and then call mirror_rows on each chunk
    `mirror_rows` will mirror such that [1,2,3] will be [1,2,3,2,1]
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex 
      |> Enum.chunk(3)
      |> Enum.map(&mirror_rows/1)
      |> List.flatten
      |> Enum.with_index
      
      %Identicon.Image{image | grid: grid}

  end

  def mirror_rows(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    
    grid = Enum.filter(grid, fn({code, _index}) -> rem(code,2)==0 end)
    %Identicon.Image{image | grid: grid}

  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
      pixel_map = 
        Enum.map grid, fn({ _code, index}) ->
        horizontal = rem(index, 5)*50
        vertical = div(index, 5)*50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal+50, vertical+50}

        {top_left, bottom_right}
      end
      %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each pixel_map , fn({start,stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
