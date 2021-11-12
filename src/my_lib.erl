-module(my_lib).

-author(john).

-author(paul).

-author(george).

-author(ringo).

-export([my_life/1]).

my_life(NewPlaces) ->
    Places = db:get_all(places),
    UpdatedPlaces = [NewPlace
                     || NewPlace <- NewPlaces,
                        lists:member(NewPlace, Places)],
    lists:foreach(fun (Place) -> db:insert(places, Place)
                  end,
                  UpdatedPlaces),
    DeletedPlaces = [Place
                     || Place <- Places, not lists:member(Place, NewPlaces)],
    db:delete(places, DeletedPlaces),
    Moments = [Moment
               || Place <- Places, Moment <- places:moments(Place)],
    People = [Person
              || Moment <- Moments,
                 Person
                     <- moments:lovers(Moment) ++ moments:friends(Moment)],
    {Dead, Living} = lists:partition(fun person:is_dead/1,
                                     People),
    lists:foreach(fun person:love/1, Dead ++ Living),
    You = db:get_first(people),
    [] = [Person
          || Person <- People, person:comparable(Person, You)],
    ok = love:update(),
    UpdatedMemories = [moments:meaning(Moment, null)
                       || Moment <- Moments],
    db:update(moments, UpdatedMemories),
    my_life(You, People, UpdatedMemories).

my_life(You, People, Things) ->
    case rand:uniform(5) of
        1 ->
            timer:sleep(rand:uniform(100) + 100),
            person:think_about(People);
        2 ->
            timer:sleep(rand:uniform(100) + 100),
            moments:think_about(Things);
        _ -> dont_stop_now
    end,
    person:love(You),
    my_life(You, People, Things).
