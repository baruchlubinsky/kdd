defmodule Plotly.Charts do

  def stacked_bar(data, group1, group2) do
    labels = Enum.map(data, &elem(&1, 0))
    values1 = Enum.map(data, &elem(&1, 1))
    values2 = Enum.map(data, &elem(&1, 2))

    """
    var trace1 = {
      x: #{inspect(labels)},
      y: #{inspect(values1)},
      name: #{inspect(group1)},
      type: 'bar'
    };

    var trace2 = {
      x: #{inspect(labels)},
      y: #{inspect(values2)},
      name: #{inspect(group2)},
      type: 'bar'
    };

    var data = [trace1, trace2];
    var layout = {barmode: 'group'};
    """

  end

end
