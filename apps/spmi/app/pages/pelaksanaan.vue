<template>
  <main class="mx-auto w-full max-w-360 bg-white px-4 py-6 tablet:px-8 desktop:px-15">
    <!-- Breadcrumb -->
    <nav :aria-label="t('pelaksanaan.breadcrumb.current')" class="mb-5">
      <ol
        class="flex flex-wrap items-center gap-2 text-body-sm text-placeholder"
      >
        <li>
          <i
            :aria-label="t('pelaksanaan.breadcrumb.home')"
            class="si-heroicon-solid-home text-title-sm"
          />
        </li>
        <li aria-hidden="true">
          <i class="si-heroicon-outline-chevron-right text-caption-md" />
        </li>
        <li>{{ t('pelaksanaan.breadcrumb.root') }}</li>
        <li aria-hidden="true">
          <i class="si-heroicon-outline-chevron-right text-caption-md" />
        </li>
        <li>{{ t('pelaksanaan.breadcrumb.process') }}</li>
        <li aria-hidden="true">
          <i class="si-heroicon-outline-chevron-right text-caption-md" />
        </li>
        <li class="font-medium text-main" aria-current="page">
          {{ t('pelaksanaan.breadcrumb.current') }}
        </li>
      </ol>
    </nav>

    <!-- Header + filters -->
    <header
      class="mb-5 flex flex-col gap-4 tablet:flex-row tablet:items-end tablet:justify-between"
    >
      <div class="flex items-center gap-2">
        <h1 class="text-heading-xl font-semibold text-main">
          {{ t('pelaksanaan.title') }}
        </h1>

        <span class="text-body-md text-placeholder" aria-hidden="true">
          |
        </span>

        <p class="text-body-md text-placeholder">
          {{ t('pelaksanaan.subtitle') }}
        </p>
      </div>

      <div class="flex flex-col gap-4 tablet:flex-row tablet:items-end">
        <!-- Unit filter -->
        <label class="flex flex-col gap-1.5">
          <span class="text-label-md font-medium text-main">
            {{ t('pelaksanaan.filter.unit_label') }}
          </span>

          <SDropdown
            v-model="selectedUnit"
            key-label="name"
            class="w-full tablet:w-56"
            data-testid="pelaksanaan-filter-unit"
          >
            <SDropdownItem
              v-for="option in unitOptions"
              :key="option.id"
              :value="option"
            >
              {{ option.name }}
            </SDropdownItem>
          </SDropdown>
        </label>

        <!-- Period filter -->
        <label class="flex flex-col gap-1.5">
          <span class="text-label-md font-medium text-main">
            {{ t('pelaksanaan.filter.period_label') }}
          </span>

          <SDropdown
            v-model="selectedPeriod"
            key-label="label"
            :placeholder="t('pelaksanaan.filter.period_placeholder')"
            :loading="isPeriodsLoading"
            class="w-full tablet:w-64"
            data-testid="pelaksanaan-filter-period"
          >
            <SDropdownItem
              v-for="option in periodOptions"
              :key="option.id"
              :value="option"
            >
              {{ option.label }}
            </SDropdownItem>
          </SDropdown>
        </label>
      </div>
    </header>

    <!-- Error -->
    <p
      v-if="errorMessage"
      class="mb-4 text-body-md text-danger-main"
      role="alert"
    >
      {{ errorMessage }}
    </p>

    <!-- Table -->
    <SDataTable
      v-model:page="page"
      v-model:per-page="perPage"
      :data="implementations"
      :total="implementations.length"
      :loading="isLoading"
      row-key="id"
      show-numbering
      paginated
      show-footer
      data-testid="pelaksanaan-table"
    >
      <!-- Unit -->
      <SDataTableColumn field="unit">
        <template #header>
          {{ t('pelaksanaan.table.unit') }}
        </template>

        <template #default="{ row }">
          {{ row.unit.name }}
        </template>
      </SDataTableColumn>

      <!-- Audit -->
      <SDataTableColumn field="audit_name">
        <template #header>
          {{ t('pelaksanaan.table.audit') }}
        </template>

        <template #default="{ row }">
          {{ row.audit_name }}
        </template>
      </SDataTableColumn>

      <!-- Instrument -->
      <SDataTableColumn field="instrument">
        <template #header>
          {{ t('pelaksanaan.table.instrument') }}
        </template>

        <template #default="{ row }">
          {{ row.instrument }}
        </template>
      </SDataTableColumn>

      <!-- Filling date -->
      <SDataTableColumn field="filling_date">
        <template #header>
          {{ t('pelaksanaan.table.filling_time') }}
        </template>

        <template #default="{ row }">
          {{ formatDateRange(row.filling_date) }}
        </template>
      </SDataTableColumn>

      <!-- Progress -->
      <SDataTableColumn field="filling_progress" width="240">
        <template #header>{{ t('pelaksanaan.table.progress') }}</template>

        <template #default="{ row }">
          <div class="flex flex-col gap-1">
            <div class="flex items-center gap-2">
              <div
                class="relative h-2 flex-1 overflow-hidden rounded-full bg-[#EAECF0]"
                role="progressbar"
                :aria-label="t('pelaksanaan.table.progress')"
                :aria-valuemin="0"
                :aria-valuemax="100"
                :aria-valuenow="row.filling_progress"
              >
                <div
                  class="h-full rounded-full bg-[#F2600C] transition-[width] duration-400 ease-in-out"
                  :style="{ width: `${row.filling_progress}%` }"
                />
              </div>

              <i
                v-if="row.filling_progress === 100"
                class="si-heroicon-solid-check-circle shrink-0 text-title-sm text-[#12B76A]"
                :aria-label="t('pelaksanaan.table.complete')"
              />

              <span
                v-else
                class="shrink-0 text-label-sm font-medium text-[#344054]"
              >
                {{ row.filling_progress }}%
              </span>
            </div>

            <span class="text-caption-sm text-[#98A2B3]">
              {{
                t('pelaksanaan.table.indicator_filled', indicatorCounts(row))
              }}
            </span>
          </div>
        </template>
      </SDataTableColumn>

      <!-- Action -->
      <SDataTableColumn field="action" width="120">
        <template #header>
          {{ t('pelaksanaan.table.action') }}
        </template>

        <template #default="{ row }">
          <SButton
            outlined
            size="sm"
            variant="primary"
            class="!border-[#F2600C] !text-[#F2600C] hover:!bg-[#FFF3EA]"
            :data-testid="`pelaksanaan-view-button-${row.id}`"
            @click="onView(row)"
          >
            {{ t('pelaksanaan.table.view') }}
          </SButton>
        </template>
      </SDataTableColumn>

      <!-- Empty state -->
      <template #empty>
        <p class="py-8 text-center text-body-md text-placeholder">
          {{
            isLoading
              ? t('pelaksanaan.state.loading')
              : t('pelaksanaan.state.empty')
          }}
        </p>
      </template>
    </SDataTable>
  </main>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import {
  SButton,
  SDataTable,
  SDataTableColumn,
  SDropdown,
  SDropdownItem,
} from '@sutekipub/sicoco-v3-next';

type Unit = {
  id: string;
  name: string;
};

type Period = {
  id: string;
  label: string;
};

interface Implementation {
  id: string;
  period_id: string;
  unit: Unit;
  audit_name: string;
  instrument: string;
  filling_date: {
    start: string;
    end: string;
  };
  filling_progress: number;
  indicator_filled?: number;
  indicator_total?: number;
}

const { t, locale } = useI18n();

const params = useQuerySync('period_id', 'unit_id');

const implementations = ref<Implementation[]>([]);
const units = ref<Unit[]>([]);
const periods = ref<Period[]>([]);

const isLoading = ref(true);
const isPeriodsLoading = ref(true);
const errorMessage = ref('');

const page = ref(1);
const perPage = ref<number>(10);

const unitOptions = computed<Unit[]>(() => [
  {
    id: '',
    name: t('pelaksanaan.filter.unit_all'),
  },
  ...units.value,
]);

const periodOptions = computed<Period[]>(() => periods.value);

const selectedUnit = computed<Unit>({
  get: () =>
    unitOptions.value.find((option) => option.id === params.unit_id) ??
    unitOptions.value[0],

  set: (option) => {
    params.unit_id = option?.id ?? '';
  },
});

const selectedPeriod = computed<Period | undefined>({
  get: () =>
    periodOptions.value.find((option) => option.id === params.period_id),

  set: (option) => {
    params.period_id = option?.id ?? '';
  },
});

function formatDateRange({ start, end }: Implementation['filling_date']) {
  const formatter = new Intl.DateTimeFormat(
    locale.value === 'en' ? 'en-GB' : 'id-ID',
    {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    },
  );

  return `${formatter.format(new Date(start))} – ${formatter.format(
    new Date(end),
  )}`;
}

function onView(_row: Implementation) {
  // Detail route is out of scope:
  // no detail endpoint is provided by the API.
}

/**
 * The current API only provides filling_progress.
 *
 * The Figma shows the indicator count using a 30-indicator
 * baseline, so we derive the filled count from the percentage.
 *
 * Examples:
 * 0%   -> 0/30
 * 40%  -> 12/30
 * 75%  -> 23/30
 * 100% -> 30/30
 *
 * If the API later provides indicator_filled and indicator_total,
 * those values will automatically be used instead.
 */
function indicatorCounts(row: Implementation) {
  const total = row.indicator_total ?? 30;

  const filled =
    row.indicator_filled ?? Math.round((row.filling_progress / 100) * total);

  return {
    filled,
    total,
  };
}

async function loadImplementations() {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    const query: Record<string, string> = {};

    if (params.period_id) {
      query.period_id = params.period_id;
    }

    if (params.unit_id) {
      query.unit_id = params.unit_id;
    }

    const response = await $fetch<{
      implementations: Implementation[];
    }>('/api/implementations', {
      query,
    });

    implementations.value = response.implementations;
    page.value = 1;
  } catch {
    errorMessage.value = t('pelaksanaan.state.error');
    implementations.value = [];
  } finally {
    isLoading.value = false;
  }
}

async function loadUnits() {
  try {
    const response = await $fetch<{
      units: Unit[];
    }>('/api/units');

    units.value = response.units;
  } catch {
    units.value = [];
  }
}

async function loadPeriods() {
  isPeriodsLoading.value = true;

  try {
    const response = await $fetch<{
      periods: Period[];
    }>('/api/periods');

    periods.value = response.periods;
  } catch {
    periods.value = [];
  } finally {
    isPeriodsLoading.value = false;
  }
}

watch(
  () => [params.period_id, params.unit_id],
  () => {
    loadImplementations();
  },
);

onMounted(() => {
  loadUnits();
  loadPeriods();
  loadImplementations();
});
</script>

<style scoped>
/*
 * SDataTable renders its own header markup internally, so it can't be
 * targeted through the #header slot (that slot only fills the header
 * cell's text, not the wrapping element). :deep() still works here
 * because Vue tags SDataTable's own root node with this component's
 * scope id, and a plain CSS descendant combinator matches any thead/th
 * further inside it regardless of whether those inner nodes carry the
 * scope id themselves.
 *
 * Covers both a native <table> implementation (thead/th) and a
 * grid-based implementation (role="columnheader") as a fallback.
 * If neither selector matches in the rendered DOM, inspect the actual
 * table markup in devtools and adjust the selector below accordingly.
 */
:deep(thead th),
:deep([role='columnheader']) {
  background-color: #f2600c !important;
  color: #ffffff !important;
  font-weight: 600;
}
</style>