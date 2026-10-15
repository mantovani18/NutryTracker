import { useEffect, useMemo, useState } from 'react'
import { Plus, Search, X } from 'lucide-react'

export type Food = { name: string; category: string; serving: string; grams: number; calories: number; source: string; id?: string }
export type SelectedFood = { name: string; grams: number; calories: number }

function normalize(value: string) {
  return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLocaleLowerCase().replace(/\s+/g, ' ').trim()
}

export default function FoodPicker({ foods, initialFoods = [], onCreateFood }: { foods: Food[]; initialFoods?: SelectedFood[]; onCreateFood: (food: Food) => Promise<void> }) {
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState<SelectedFood[]>(initialFoods)
  const [amount, setAmount] = useState('')
  const [newFoodOpen, setNewFoodOpen] = useState(false)
  const [newName, setNewName] = useState('')
  const [newCalories, setNewCalories] = useState('')
  const [message, setMessage] = useState('')
  useEffect(() => { setSelected(initialFoods) }, [initialFoods])
  const results = useMemo(() => {
    const search = normalize(query)
    if (search.length < 2) return []
    return foods.filter(food => normalize(`${food.name} ${food.category}`).includes(search) && !selected.some(item => normalize(item.name) === normalize(food.name))).slice(0, 8)
  }, [foods, query, selected])

  function choose(food: Food) {
    const grams = Number(amount)
    if (!Number.isFinite(grams) || grams <= 0) { setMessage('Informe uma quantidade maior que zero em gramas.'); return }
    setSelected(items => [...items, { name: food.name, grams, calories: Math.round(food.calories * grams / 100) }])
    setQuery('')
    setAmount('')
    setMessage('')
  }
  function remove(name: string) { setSelected(items => items.filter(item => item.name !== name)) }
  async function createFood(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const name = newName.replace(/\s+/g, ' ').trim()
    const calories = Number(newCalories)
    if (!name || !Number.isFinite(calories) || calories < 0) { setMessage('Informe nome e calorias válidos.'); return }
    try {
      await onCreateFood({ name, category: 'Meus alimentos', serving: '100 g', grams: 100, calories, source: 'Cadastrado pelo usuário' })
      setNewName('')
      setNewCalories('')
      setNewFoodOpen(false)
      setMessage('Alimento adicionado à sua lista.')
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Não foi possível cadastrar o alimento.')
    }
  }
  return <div className="food-picker">
    <label className="field">Alimento pesquisável
      <div className="food-search-input">
        <Search size={16} />
        <input value={query} onChange={event => setQuery(event.target.value)} placeholder="Digite o nome do alimento" autoComplete="off" />
        {query && <button type="button" className="food-clear" onClick={() => setQuery('')} title="Limpar busca"><X size={14} /></button>}
      </div>
    </label>
    <div className="form-grid">
      <label className="field">Quantidade (g)<input type="number" min="0.1" step="0.1" value={amount} onChange={event => setAmount(event.target.value)} placeholder="Ex: 150" /></label>
      <button type="button" className="secondary" onClick={() => setNewFoodOpen(value => !value)}><Plus size={15} /> Adicionar novo alimento</button>
    </div>
    {results.length > 0 && <div className="food-results">{results.map(food => <button type="button" className="food-result" key={`${food.id || food.name}-${food.category}`} onClick={() => choose(food)}><span><strong>{food.name}</strong><small>{food.category} · {food.calories} kcal/100 g</small></span><b>Adicionar</b></button>)}</div>}
    {newFoodOpen && <form className="panel" onSubmit={createFood}><Field label="Nome do alimento" value={newName} onChange={(event: React.ChangeEvent<HTMLInputElement>) => setNewName(event.target.value)} required /><Field label="Calorias por 100 g (kcal)" type="number" min="0" step="0.1" value={newCalories} onChange={(event: React.ChangeEvent<HTMLInputElement>) => setNewCalories(event.target.value)} required /><button className="primary" type="submit">Salvar alimento</button></form>}
    {selected.length > 0 && <div className="food-selected-list">{selected.map(item => <div className="food-selected" key={item.name}><span>{item.name} · {item.grams} g</span><b>{item.calories} kcal</b><button type="button" className="food-clear" onClick={() => remove(item.name)} title="Remover alimento"><X size={14} /></button></div>)}</div>}
    <input type="hidden" name="foods" value={JSON.stringify(selected)} required />
    {message && <p className="form-hint">{message}</p>}
  </div>
}

function Field({ label, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string }) {
  return <label className="field">{label}<input {...props} /></label>
}
