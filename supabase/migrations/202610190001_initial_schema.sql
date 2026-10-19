-- BENISAT Mission Control · esquema sencillo para una sola cuenta.
-- Aplicar SOLO en un proyecto Supabase nuevo/vacío.
-- Seguridad: cada fila pertenece al usuario autenticado y RLS limita el acceso a sus propias filas.

create table public.actions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  description text,
  area text not null default 'general',
  status text not null default 'pendiente' check (status in ('pendiente','en_curso','bloqueada','hecha')),
  priority text not null default 'normal' check (priority in ('baja','normal','alta','urgente')),
  due_date date,
  estimated_cost numeric(10,2) not null default 0 check (estimated_cost >= 0),
  actual_cost numeric(10,2) not null default 0 check (actual_cost >= 0),
  next_step text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.milestones (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  description text,
  due_date date,
  status text not null default 'pendiente' check (status in ('pendiente','en_curso','completado')),
  source_url text,
  created_at timestamptz not null default now()
);

create table public.sponsors (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  contact_name text,
  contact_email text,
  contact_phone text,
  contribution_type text not null default 'pendiente',
  contribution_value numeric(10,2) not null default 0 check (contribution_value >= 0),
  status text not null default 'posible',
  notes text,
  created_at timestamptz not null default now()
);

create table public.financial_transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  kind text not null check (kind in ('ingreso','gasto')),
  category text not null,
  description text not null,
  amount numeric(10,2) not null check (amount > 0),
  transaction_date date not null default current_date,
  related_sponsor_id uuid references public.sponsors(id) on delete set null,
  receipt_url text,
  notes text,
  created_at timestamptz not null default now()
);

create table public.publications (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  platform text not null default 'Instagram',
  planned_date date,
  published_date date,
  status text not null default 'idea',
  public_url text,
  reach_count integer check (reach_count is null or reach_count >= 0),
  evidence_url text,
  notes text,
  created_at timestamptz not null default now()
);

create table public.evidence (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  evidence_type text not null default 'documento',
  url text not null,
  related_action_id uuid references public.actions(id) on delete set null,
  description text,
  created_at timestamptz not null default now()
);

create index actions_status_due_date_idx on public.actions(status, due_date);
create index milestones_due_date_idx on public.milestones(due_date);
create index financial_transactions_date_idx on public.financial_transactions(transaction_date desc);
create index publications_planned_date_idx on public.publications(planned_date);

-- Activar seguridad por fila y permitir CRUD solo sobre los datos del usuario autenticado.
alter table public.actions enable row level security;
alter table public.milestones enable row level security;
alter table public.sponsors enable row level security;
alter table public.financial_transactions enable row level security;
alter table public.publications enable row level security;
alter table public.evidence enable row level security;

create policy "solo mis acciones" on public.actions
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "solo mis hitos" on public.milestones
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "solo mis patrocinadores" on public.sponsors
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "solo mis movimientos" on public.financial_transactions
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "solo mis publicaciones" on public.publications
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "solo mis evidencias" on public.evidence
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.actions,
  public.milestones,
  public.sponsors,
  public.financial_transactions,
  public.publications,
  public.evidence
to authenticated;
