-- BENISAT Mission Control: esquema inicial
-- Aplicar en una instancia nueva de Supabase. Revisar las políticas antes de usar datos reales.
create extension if not exists pgcrypto;

create type public.team_role as enum ('coordinator', 'member', 'finance');
create type public.action_status as enum ('backlog', 'planned', 'in_progress', 'blocked', 'done', 'cancelled');
create type public.action_priority as enum ('low', 'normal', 'high', 'urgent');
create type public.transaction_kind as enum ('income', 'expense');

create table public.team_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role public.team_role not null default 'member',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.actions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  area text not null default 'general',
  status public.action_status not null default 'backlog',
  priority public.action_priority not null default 'normal',
  responsible_user_id uuid references public.team_members(user_id) on delete set null,
  due_date date,
  estimated_cost numeric(10,2) not null default 0 check (estimated_cost >= 0),
  actual_cost numeric(10,2) not null default 0 check (actual_cost >= 0),
  next_step text,
  created_by uuid references public.team_members(user_id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.milestones (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  due_date date,
  status public.action_status not null default 'planned',
  source_url text,
  created_at timestamptz not null default now()
);

create table public.sponsors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_name text,
  contact_email text,
  contact_phone text,
  contribution_type text not null default 'pending',
  contribution_value numeric(10,2) not null default 0 check (contribution_value >= 0),
  status text not null default 'prospect',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.financial_transactions (
  id uuid primary key default gen_random_uuid(),
  kind public.transaction_kind not null,
  category text not null,
  description text not null,
  amount numeric(10,2) not null check (amount > 0),
  transaction_date date not null default current_date,
  related_sponsor_id uuid references public.sponsors(id) on delete set null,
  receipt_url text,
  recorded_by uuid references public.team_members(user_id) on delete set null,
  notes text,
  created_at timestamptz not null default now()
);

create table public.publications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  platform text not null default 'Instagram',
  planned_date date,
  published_date date,
  status text not null default 'idea',
  public_url text,
  reach_count integer check (reach_count is null or reach_count >= 0),
  evidence_url text,
  notes text,
  created_by uuid references public.team_members(user_id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.evidence (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  evidence_type text not null default 'document',
  url text not null,
  related_action_id uuid references public.actions(id) on delete set null,
  description text,
  created_by uuid references public.team_members(user_id) on delete set null,
  created_at timestamptz not null default now()
);

create index actions_status_due_date_idx on public.actions(status, due_date);
create index actions_responsible_user_id_idx on public.actions(responsible_user_id);
create index milestones_due_date_idx on public.milestones(due_date);
create index financial_transactions_date_idx on public.financial_transactions(transaction_date desc);
create index publications_planned_date_idx on public.publications(planned_date);

-- Funciones auxiliares para evitar políticas recursivas al consultar team_members.
create or replace function public.is_active_team_member()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.team_members tm
    where tm.user_id = (select auth.uid()) and tm.active = true
  );
$$;

create or replace function public.has_team_role(allowed_roles public.team_role[])
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.team_members tm
    where tm.user_id = (select auth.uid())
      and tm.active = true
      and tm.role = any(allowed_roles)
  );
$$;

alter table public.team_members enable row level security;
alter table public.actions enable row level security;
alter table public.milestones enable row level security;
alter table public.sponsors enable row level security;
alter table public.financial_transactions enable row level security;
alter table public.publications enable row level security;
alter table public.evidence enable row level security;

-- Un miembro activo puede ver el directorio mínimo del equipo.
create policy "team members can read active team directory"
on public.team_members for select to authenticated
using (public.is_active_team_member());

-- Solo coordinación administra roles y altas de miembros.
create policy "coordinators manage team members"
on public.team_members for all to authenticated
using (public.has_team_role(array['coordinator']::public.team_role[]))
with check (public.has_team_role(array['coordinator']::public.team_role[]));

-- Tareas: el equipo puede leerlas; cada miembro edita sus tareas; coordinación puede gestionarlas todas.
create policy "team reads actions"
on public.actions for select to authenticated
using (public.is_active_team_member());

create policy "team creates actions"
on public.actions for insert to authenticated
with check (public.is_active_team_member() and (created_by is null or created_by = (select auth.uid())));

create policy "assigned members or coordinators update actions"
on public.actions for update to authenticated
using (
  public.has_team_role(array['coordinator']::public.team_role[])
  or responsible_user_id = (select auth.uid())
)
with check (
  public.has_team_role(array['coordinator']::public.team_role[])
  or responsible_user_id = (select auth.uid())
);

create policy "coordinators delete actions"
on public.actions for delete to authenticated
using (public.has_team_role(array['coordinator']::public.team_role[]));

-- Los hitos y las publicaciones se comparten entre miembros; coordinación administra borrados.
create policy "team reads milestones" on public.milestones for select to authenticated using (public.is_active_team_member());
create policy "team manages milestones" on public.milestones for all to authenticated using (public.has_team_role(array['coordinator']::public.team_role[])) with check (public.has_team_role(array['coordinator']::public.team_role[]));

create policy "team reads publications" on public.publications for select to authenticated using (public.is_active_team_member());
create policy "team manages publications" on public.publications for all to authenticated using (public.is_active_team_member()) with check (public.is_active_team_member());

-- Información financiera: todos los miembros pueden consultar; solo coordinación/finanzas modifica.
create policy "team reads sponsors" on public.sponsors for select to authenticated using (public.is_active_team_member());
create policy "finance roles manage sponsors" on public.sponsors for all to authenticated
using (public.has_team_role(array['coordinator','finance']::public.team_role[]))
with check (public.has_team_role(array['coordinator','finance']::public.team_role[]));

create policy "team reads transactions" on public.financial_transactions for select to authenticated using (public.is_active_team_member());
create policy "finance roles manage transactions" on public.financial_transactions for all to authenticated
using (public.has_team_role(array['coordinator','finance']::public.team_role[]))
with check (public.has_team_role(array['coordinator','finance']::public.team_role[]));

create policy "team reads evidence" on public.evidence for select to authenticated using (public.is_active_team_member());
create policy "team manages evidence" on public.evidence for all to authenticated using (public.is_active_team_member()) with check (public.is_active_team_member());

-- Dar acceso de tabla a usuarios autenticados; RLS decide qué filas pueden usar.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.team_members, public.actions, public.milestones, public.sponsors, public.financial_transactions, public.publications, public.evidence to authenticated;
grant execute on function public.is_active_team_member() to authenticated;
grant execute on function public.has_team_role(public.team_role[]) to authenticated;

-- Importante: no se crea automáticamente un coordinador. La primera cuenta coordinadora
-- debe incorporarse manualmente desde el panel SQL de Supabase por una persona administradora.
