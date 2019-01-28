function require_game_objects()
    local objects = {}
    local components = {}
    local next_id = 0

    local game_objects = {
        new = function(self, name)
            local object_components = {}

            new_game_object = {
                id = next_id,
                name = name,
                add_component = function(self, component)
                    add(components, component)
                    object_components[component.name] = component
                    component.game_object = self
                end,
                get_component = function(self, name)
                    return object_components[name]
                end,
            }

            next_id += 1
            objects[name] = new_game_object

            return new_game_object
        end,

        get_by_name = function(self, name)
            return objects[name]
        end,

        init = function()
            for component in all(components) do
                if component.init then
                    component:init()
                end
            end
        end,

        late_init = function()
            for component in all(components) do
                if component.late_init then
                    component:late_init()
                end
            end
        end,

        update = function()
            for component in all(components) do
                if component.update then
                    component:update()
                end
            end
        end,

        draw = function()
            for component in all(components) do
                if component.draw then
                    component:draw()
                end
            end
        end,

        late_draw = function()
            for component in all(components) do
                if component.late_draw then
                    component:late_draw()
                end
            end
        end
    }

    return game_objects
end
