defmodule Codebattle.Task do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Codebattle.Repo

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :level,
             :examples,
             :description_ru,
             :description_en,
             :tags,
             :state,
             :origin,
             :visibility,
             :creator_id
           ]}

  @levels ~w(elementary easy medium hard)
  @states ~w(draft on_moderation active disabled)
  @origin_types ~w(github user)
  @visibility_types ~w(hidden public)

  schema "tasks" do
    field(:examples, :string)
    field(:description_ru, :string)
    field(:description_en, :string)
    field(:name, :string)
    field(:level, :string)
    field(:input_signature, {:array, :map}, default: [])
    field(:output_signature, :map, default: %{})
    field(:asserts, :string)
    field(:disabled, :boolean)
    field(:count, :integer, virtual: true)
    field(:task_id, :integer, virtual: true)
    field(:tags, {:array, :string}, default: [])
    field(:state, :string)
    field(:visibility, :string, default: "public")
    field(:origin, :string)
    field(:creator_id, :integer)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :examples,
      :description_ru,
      :description_en,
      :name,
      :level,
      :input_signature,
      :output_signature,
      :asserts,
      :disabled,
      :tags,
      :state,
      :origin,
      :visibility,
      :creator_id
    ])
    |> validate_required([:examples, :description_en, :name, :level, :asserts])
    |> validate_inclusion(:state, @states)
    |> validate_inclusion(:level, @levels)
    |> validate_inclusion(:origin, @origin_types)
    |> validate_inclusion(:visibility, @visibility_types)
    |> unique_constraint(:name)
  end

  def public(query) do
    from(t in query, where: t.visibility == "public")
  end

  def visible(query) do
    from(t in query, where: t.visibility == "public" and t.state == "active")
  end

  def list_visible(user) do
    __MODULE__
    |> filter_visibility(user)
    |> order_by([{:desc, :origin}, :state, :level, :name])
    |> Repo.all()
  end

  def filter_visibility(query, user) do
    if Codebattle.User.is_admin?(user) do
      Function.identity(query)
    else
      from(t in query,
        where: [visibility: "public", state: "active"],
        or_where: [creator_id: ^user.id]
      )
    end
  end

  def list_all_tags do
    query = """
    SELECT distinct unnest(tags) from tasks
    where visibility = 'public'
    and state = 'active'
    """

    Repo
    |> Ecto.Adapters.SQL.query!(query)
    |> Map.get(:rows)
    |> List.flatten()
  end

  def get_asserts(task) do
    task
    |> Map.get(:asserts)
    |> String.split("\n")
    |> filter_empty_items()
    |> Enum.map(&Jason.decode!/1)
  end

  def get!(id), do: Repo.get!(__MODULE__, id)
  def get(id), do: Repo.get(__MODULE__, id)

  def get_shuffled_task_ids(level) do
    from(task in Codebattle.Task, where: task.level == ^level)
    |> visible()
    |> select([x], x.id)
    |> Repo.all()
    |> Enum.shuffle()
  end

  def get_played_count(task_id) do
    from(game in Codebattle.Game, where: game.task_id == ^task_id)
    |> Repo.count()
  end

  def can_see_task?(%{visibility: "public"}, _user), do: true

  def can_see_task?(task, user), do: can_access_task?(task, user)

  def can_access_task?(task, user) do
    task.creator_id == user.id || Codebattle.User.is_admin?(user)
  end

  def change_state(task, state) do
    task
    |> changeset(%{state: state})
    |> Repo.update!()
  end

  def levels, do: @levels
  def visibility_types, do: @visibility_types
  def origin_types, do: @origin_types
  def states, do: @states

  defp filter_empty_items(items), do: items |> Enum.filter(&(&1 != ""))
end
