$categories = @(
  @{Name='Açúcares, bolos e doces'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/bolos-e-doces'},
  @{Name='Aves e frango'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/aves'},
  @{Name='Balas e chicletes'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/balas-e-chicletes'},
  @{Name='Barras de cereais'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/barras-de-cereais'},
  @{Name='Bebidas alcoólicas'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/bebidas-alcoolicas'},
  @{Name='Bebidas não alcoólicas'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/bebidas-nao-alcoolicas'},
  @{Name='Bolachas e biscoitos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/bolachas-e-biscoitos'},
  @{Name='Carne bovina'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/carne-bovina'},
  @{Name='Carne suína'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/carne-suina'},
  @{Name='Cereais e farináceos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/cereais-e-farinaceos'},
  @{Name='Chocolates'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/chocolates'},
  @{Name='Embutidos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/embutidos'},
  @{Name='Frutas e castanhas'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/frutas-e-castanhas'},
  @{Name='Frutos do mar'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/frutos-do-mar'},
  @{Name='Gorduras'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/gorduras'},
  @{Name='Iogurtes'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/iogurtes'},
  @{Name='Leguminosas'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/leguminosas'},
  @{Name='Leites e achocolatados'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/leites'},
  @{Name='Massas'; Url='https://endocrinosaude.com/tabela-de-calorias/massas/'},
  @{Name='Ovos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/ovos'},
  @{Name='Pães e torradas'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/paes'},
  @{Name='Peixes'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/peixes'},
  @{Name='Pizzas'; Url='https://endocrinosaude.com/tabela-de-calorias/pizzas/'},
  @{Name='Pratos caseiros'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/pratos-caseiros'},
  @{Name='Queijos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/queijos'},
  @{Name='Salgados e petiscos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/salgados-e-petiscos'},
  @{Name='Sanduíches'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/sanduiches'},
  @{Name='Sopas e caldos'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/sopas-e-caldos'},
  @{Name='Verduras e legumes'; Url='https://endocrinosaude.com/wordpress/tabela-de-calorias/verduras-e-legumes'}
)

$foods = [System.Collections.Generic.List[object]]::new()
foreach ($category in $categories) {
  try {
    $html = (Invoke-WebRequest -Uri $category.Url -UseBasicParsing).Content
    $rows = [regex]::Matches($html, '(?is)<tr[^>]*>(.*?)</tr>')
    foreach ($row in $rows) {
      $cells = @([regex]::Matches($row.Groups[1].Value, '(?is)<t[dh][^>]*>(.*?)</t[dh]>') | ForEach-Object {
        $text = (($_.Groups[1].Value -replace '<[^>]+>', ' ' -replace '\s+', ' ').Trim())
        [System.Net.WebUtility]::HtmlDecode($text)
      })
      $weightMatch = if ($cells.Count -ge 3) { [regex]::Match($cells[2], '(\d[\d\.,]*)') } else { $null }
      $calorieMatch = if ($cells.Count -ge 4) { [regex]::Match($cells[3], '^\s*(\d+)') } else { $null }
      if ($cells.Count -ge 4 -and $cells[0] -and $weightMatch.Success -and $calorieMatch.Success) {
        $grams = [double](($weightMatch.Groups[1].Value -replace '\.', '' -replace ',', '.'))
        $kcal = [int]$calorieMatch.Groups[1].Value
        $foods.Add([pscustomobject]@{ name=$cells[0]; category=$category.Name; serving=$cells[1]; grams=$grams; calories=$kcal; source='EndocrinoSaude' })
      }
    }
    Write-Host "$($category.Name): $($foods.Count) acumulados"
  } catch { Write-Warning "Falha: $($category.Url)" }
}

$unique = $foods | Sort-Object name, category, grams, calories -Unique
New-Item -ItemType Directory -Force -Path 'src\data' | Out-Null
$unique | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 'src\data\foodCatalog.json'
Write-Host "Importados $($unique.Count) alimentos."
