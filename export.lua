exports('KoseTut', function(esya)
    for isim, fiyat in pairs(Config.KoseTut) do
        if esya == isim then
            return fiyat
        end
    end
end)