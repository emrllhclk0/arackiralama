-- Resim alanını ekle
ALTER TABLE cars ADD COLUMN IF NOT EXISTS image_url TEXT;

-- E-ticaret siteleri resim çekmeyi engellediği için geçici olarak güvenilir (placehold.co) resimler kullanıyoruz.
UPDATE cars SET name = 'Pilsan Nevada 12V (Kırmızı)', color = '#FF0000', image_url = 'https://placehold.co/400x300/FF0000/FFFFFF.png?text=Pilsan+Nevada' WHERE id = 1;
UPDATE cars SET name = 'Audi Q7 Quattro 12V', color = '#FFFFFF', image_url = 'https://placehold.co/400x300/FFFFFF/000000.png?text=Audi+Q7' WHERE id = 2;
UPDATE cars SET name = 'Pilsan Rocket ATV 12V', color = '#0000FF', image_url = 'https://placehold.co/400x300/0000FF/FFFFFF.png?text=Rocket+ATV' WHERE id = 3;
UPDATE cars SET name = 'Pilsan Panther 12V (Siyah)', color = '#000000', image_url = 'https://placehold.co/400x300/000000/FFFFFF.png?text=Pilsan+Panther' WHERE id = 4;
UPDATE cars SET name = 'Pilsan Ranger 12V', color = '#FF0000', image_url = 'https://placehold.co/400x300/FF0000/FFFFFF.png?text=Pilsan+Ranger' WHERE id = 5;
UPDATE cars SET name = 'Pilsan Savana 12V (Bej)', color = '#F5F5DC', image_url = 'https://placehold.co/400x300/F5F5DC/000000.png?text=Pilsan+Savana' WHERE id = 6;
