defmodule Query.IncludeTest do
  use ExUnit.Case
  import FatEcto.FatQuery
  import Ecto.Query

  test "returns the query with include associated model" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"fat_hospitals" => %{"$limit" => 3}}
    }

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"fat_hospitals" => %{"$limit" => 3}},
      "$where" => %{"id" => 10}
    }

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.id == ^10 and ^true,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where and order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$limit" => 10,
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.id == ^10 and ^true,
        order_by: [asc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and left join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$left",
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.id == ^10 and ^true,
        order_by: [asc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and right join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$right",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        right_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  @tag :dev
  test "returns the query with include associated model and inner join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$inner",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"},
      "$order" => %{"id" => "$asc"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        order_by: [asc: d.id],
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and full join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$full",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        full_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include as a binary" do
    opts = %{
      "$include" => "fat_hospitals"
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :fat_hospitals),
        preload: [:fat_hospitals]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include" do
    opts = %{
      "$include" => %{"fat_hospitals" => %{"$include" => ["fat_rooms"]}}
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        limit: ^10,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and where" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        where: h.name == ^"ham" and ^true,
        limit: ^10,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models" do
    opts = %{
      "$include" => %{"fat_hospitals" => %{"$include" => ["fat_rooms", "fat_patients"]}}
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        left_join: p in assoc(h, :fat_patients),
        limit: ^10,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with where" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms", "fat_patients"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        left_join: p in assoc(h, :fat_patients),
        where: h.name == ^"ham" and ^true,
        limit: ^10,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms", "fat_patients"],
          "$order" => %{"id" => "$asc"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :fat_rooms),
        order_by: [asc: h.id],
        left_join: p in assoc(h, :fat_patients),
        limit: ^10,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include list" do
    opts = %{
      "$include" => ["fat_hospitals", "fat_patients"]
    }

    expected =
      from(d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :fat_hospitals),
        left_join: p in assoc(d, :fat_patients),
        preload: [:fat_patients, :fat_hospitals]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end
end
