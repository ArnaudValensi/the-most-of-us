function require_game_objects()
    local objects = {}
    local components = {}
    local next_id = 0

    local game_objects = {
        new = function(name)
            new_game_object = {
                id = next_id,
                name = name,
                add_component = function(self, component)
                    component.game_object = self
                end
            }

            next_id += 1
            objects[name] = new_game_object

            return new_game_object
        end,

        update = function()
            for component in all(components) do
                component:update()
            end
        end
    }

    return game_objects
end
