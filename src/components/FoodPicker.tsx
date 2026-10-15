import { useEffect, useState } from 'react'
import { Search, X } from 'lucide-react'
import catalogData from '../data/foodCatalog.json'

type Food = { name: string; category: string; serving: string; grams: number; calories: number; source: string }
const foodCatalog: Food[] = catalogData

export default function FoodPicker({ initialFoodName = '' }: { initialFoodName?: string }) {
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState<Food | null>(null)
  useEffect(() => {
    const initialFood = foodCatalog.find(food => food.name === initialFoodName)
    setSelected(initialFood || null)
    setQuery(initialFood?.name || '')
  }, [initialFoodName])
  const results = query.trim().length < 2 ? [] : foodCatalog.filter(food => `${food.name} ${food.category}`.toLocaleLowerCase().includes(query.trim().toLocaleLowerCase())).slice(0, 8)

  function choose(food: Food) {
    setSelected(food)
    setQuery(food.name)
  }

  function clear() {
    setSelected(null)
    setQuery('')
  }

  return <div className="food-picker">
    <label className="field">Alimento pesquisável
      <div className="food-search-input">
        <Search size={16} />
        <input value={query} onChange={event => { setQuery(event.target.value); setSelected(null) }} placeholder="Digite o nome do alimento" autoComplete="off" required={!selected} />
        {query && <button type="button" className="food-clear" onClick={clear} title="Limpar busca"><X size={14} /></button>}
      </div>
    </label>
    <input type="hidden" name="food" value={selected?.name || ''} required />
    {results.length > 0 && !selected && <div className="food-results">{results.map(food => <button type="button" className="food-result" key={`${food.name}-${food.category}-${food.grams}`} onClick={() => choose(food)}><span><strong>{food.name}</strong><small>{food.category} · {food.serving}</small></span><b>{food.calories} kcal</b></button>)}</div>}
    {selected && <p className="food-selected">Selecionado: {selected.name} · referência {selected.grams} g = {selected.calories} kcal</p>}
  </div>
}
