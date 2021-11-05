defmodule Codebattle.Tournament do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Tournament.Types

  @derive {Jason.Encoder,
           only: [
             :id,
             :type,
             :name,
             :state,
             :starts_at,
             :players_count,
             :data,
             :creator,
             :creator_id,
             :is_live
           ]}

  @types ~w(individual team)
  @access_types ~w(public token)
  @states ~w(upcoming waiting_participants canceled active finished)
  @difficulties ~w(elementary easy medium hard)
  @max_alive_tournaments 5
  @default_match_timeout Application.compile_env(:codebattle, :tournament_match_timeout)

  schema "tournaments" do
    field(:name, :string)
    field(:type, :string, default: "individual")
    field(:difficulty, :string, default: "elementary")
    field(:state, :string, default: "upcoming")
    field(:default_language, :string, default: "js")
    field(:players_count, :integer)
    field(:match_timeout_seconds, :integer, default: @default_match_timeout)
    field(:step, :integer, default: 0)
    field(:starts_at, :utc_datetime)
    field(:meta, :map, default: %{})
    field(:last_round_started_at, :naive_datetime)
    field(:access_type, :string, default: "public")
    field(:access_token, :string)
    field(:module, :any, virtual: true, default: Tournament.Individual)
    field(:is_live, :boolean, virtual: true, default: false)
    embeds_one(:data, Types.Data, on_replace: :delete)

    belongs_to(:creator, Codebattle.User)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :difficulty,
      :type,
      :access_type,
      :access_token,
      :step,
      :state,
      :starts_at,
      :match_timeout_seconds,
      :last_round_started_at,
      :players_count,
      :default_language,
      :meta
    ])
    |> cast_embed(:data)
    |> validate_inclusion(:state, @states)
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:access_type, @access_types)
    |> validate_inclusion(:difficulty, @difficulties)
    |> validate_required([:name, :starts_at])
    |> validate_alive_maximum(params)
    |> add_creator(params["creator"] || params[:creator])
  end

  def add_creator(changeset, nil), do: changeset

  def add_creator(changeset, creator) do
    change(changeset, %{creator: creator})
  end

  def validate_alive_maximum(changeset, params) do
    alive_count = params["alive_count"] || 0

    if alive_count < @max_alive_tournaments do
      changeset
    else
      add_error(
        changeset,
        :base,
        "Too many live tournaments: #{alive_count}, maximum allowed: #{@max_alive_tournaments}"
      )
    end
  end

  def types, do: @types
  def access_types, do: @access_types
  def difficulties, do: @difficulties
end
