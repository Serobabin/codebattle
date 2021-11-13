defmodule Codebattle.Bot.Builder do
  @moduledoc """
    generate bots for different environments
  """
  import Ecto.Query

  alias Codebattle.User
  alias Codebattle.Repo
  alias Codebattle.Game.LiveGames

  def build(params \\ %{}) do
    query =
      from(
        user in User,
        where: user.is_bot == true,
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    bot = Repo.one!(query)
    Map.merge(bot, params)
  end

  def build_list(count, params \\ %{}) do
    query =
      from(
        user in User,
        where: user.is_bot == true,
        order_by: fragment("RANDOM()"),
        limit: ^count
      )

    query
    |> Repo.all()
    |> Enum.map(&Map.merge(&1, params))
  end

  def build_free_bot do
    playing_bots_id =
      LiveGames.get_playing_bots()
      |> Enum.map(fn bot -> bot.id end)

    query =
      from(
        user in User,
        where: user.id not in ^playing_bots_id and user.is_bot == true,
        limit: 1
      )

    Repo.one(query)
  end
end
