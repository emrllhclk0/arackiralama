-- ============================================================
-- Akülü Araç Kiralama Takip Sistemi - Supabase Veritabanı Şeması
-- ============================================================

-- 1. CARS (Araçlar) Tablosu
-- ============================================================
CREATE TABLE IF NOT EXISTS cars (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'rented')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Cars tablosu için index
CREATE INDEX idx_cars_status ON cars(status);

-- 2. RENTALS (Kiralamalar) Tablosu
-- ============================================================
CREATE TABLE IF NOT EXISTS rentals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  car_id INTEGER NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  total_price INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rentals tablosu için indexler
CREATE INDEX idx_rentals_status ON rentals(status);
CREATE INDEX idx_rentals_car_id ON rentals(car_id);
CREATE INDEX idx_rentals_start_time ON rentals(start_time);
CREATE INDEX idx_rentals_created_at ON rentals(created_at);

-- 3. RENTAL_EXTENSIONS (Ekstra Süre Kayıtları) Tablosu
-- ============================================================
CREATE TABLE IF NOT EXISTS rental_extensions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rental_id UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
  added_minutes INTEGER NOT NULL,
  added_price INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rental extensions için index
CREATE INDEX idx_rental_extensions_rental_id ON rental_extensions(rental_id);

-- ============================================================
-- SQL FONKSİYONLARI (RPC)
-- ============================================================

-- Günlük Ciro Hesaplama Fonksiyonu
-- Belirtilen tarihteki tamamlanmış kiralamaların toplam fiyatını döndürür
CREATE OR REPLACE FUNCTION get_daily_revenue(target_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN COALESCE(
    (
      SELECT SUM(total_price)
      FROM rentals
      WHERE status = 'completed'
        AND DATE(start_time AT TIME ZONE 'Europe/Istanbul') = target_date
    ),
    0
  );
END;
$$ LANGUAGE plpgsql;

-- Aylık Ciro Hesaplama Fonksiyonu
-- Belirtilen yıl ve aydaki tamamlanmış kiralamaların toplam fiyatını döndürür
CREATE OR REPLACE FUNCTION get_monthly_revenue(target_year INTEGER, target_month INTEGER)
RETURNS INTEGER AS $$
BEGIN
  RETURN COALESCE(
    (
      SELECT SUM(total_price)
      FROM rentals
      WHERE status = 'completed'
        AND EXTRACT(YEAR FROM start_time AT TIME ZONE 'Europe/Istanbul') = target_year
        AND EXTRACT(MONTH FROM start_time AT TIME ZONE 'Europe/Istanbul') = target_month
    ),
    0
  );
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SEED DATA (Başlangıç Verileri) - 6 Adet Akülü Araç
-- ============================================================
INSERT INTO cars (name, color) VALUES
  ('Araç 1', '#E53935'),   -- Kırmızı
  ('Araç 2', '#1E88E5'),   -- Mavi
  ('Araç 3', '#43A047'),   -- Yeşil
  ('Araç 4', '#FB8C00'),   -- Turuncu
  ('Araç 5', '#8E24AA'),   -- Mor
  ('Araç 6', '#00ACC1');   -- Turkuaz

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Basit yapı: Herkesin okuma/yazma yetkisi var (tek kullanıcılı sistem)
-- ============================================================
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE rentals ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental_extensions ENABLE ROW LEVEL SECURITY;

-- Cars için policy
CREATE POLICY "Allow all operations on cars"
  ON cars FOR ALL
  USING (true)
  WITH CHECK (true);

-- Rentals için policy
CREATE POLICY "Allow all operations on rentals"
  ON rentals FOR ALL
  USING (true)
  WITH CHECK (true);

-- Rental extensions için policy
CREATE POLICY "Allow all operations on rental_extensions"
  ON rental_extensions FOR ALL
  USING (true)
  WITH CHECK (true);
