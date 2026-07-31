-- Assign coherent images to businesses and offers that had none.
-- Unsplash URLs match the format already used across the app (?w=400).

update businesses
set image = 'https://images.unsplash.com/photo-1579751626657-72bc17010498?w=400'  -- pizza oven
where id = 'd0000000-0000-0000-0000-000000000014';  -- Pizzería Toscana

update businesses
set image = 'https://images.unsplash.com/photo-1509365465985-25d11c17e812?w=400'  -- bakery bread
where id = 'd0000000-0000-0000-0000-000000000010';  -- Panadería San Pedro

update businesses
set image = 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400'  -- chocolate dessert
where id = 'd0000000-0000-0000-0000-000000000015';  -- Dulcería El Manjar

update offers
set image = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400'  -- sliced bread loaf
where id = 'e0000000-0000-0000-0000-000000000100';  -- Pan de molde artesanal

update offers
set image = 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400'  -- empanadas
where id = 'e0000000-0000-0000-0000-000000000101';  -- Empanadas de verde (x6)

update offers
set image = 'https://images.unsplash.com/photo-1618040996337-56904b7850b9?w=400'  -- quesadillas
where id = 'e0000000-0000-0000-0000-000000000110';  -- Quesadillas quiteñas (x4)

update offers
set image = 'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?w=400'  -- sweet corn tamales
where id = 'e0000000-0000-0000-0000-000000000111';  -- Humitas dulces (x3)

update offers
set image = 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400'  -- margherita pizza
where id = 'e0000000-0000-0000-0000-000000000108';  -- Pizza Margherita grande

update offers
set image = 'https://images.unsplash.com/photo-1594398901394-4e34939a4fd0?w=400'  -- focaccia
where id = 'e0000000-0000-0000-0000-000000000109';  -- Focaccia con romero
